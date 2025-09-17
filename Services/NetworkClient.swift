//
//  NetworkClient.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 15/9/25.
//

import Foundation

/// Единый сетевой клиент приложения. Работает через URLSession.
/// Сигнатуры методов сохранены, чтобы не менять ViewModel.
actor NetworkClient {
    // MARK: - Singleton для простоты DI
    static let shared = NetworkClient()

    // MARK: - Конфигурация
    private let apiKey: String = Constants.apiKey
    private let baseURL = URL(string: "https://api.rasp.yandex.net/v3.0")!
    private let session: URLSession
    private let decoder: JSONDecoder

    // Кэш большого справочника станций, чтобы не грузить каждый раз
    private var stationsCatalogCache: StationsListResponse? = nil

    init(session: URLSession = .shared) {
        self.session = session
        let dec = JSONDecoder()
        // У Яндекса snake_case ключи → конвертируем в camelCase автоматически
        dec.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = dec
    }

    // MARK: - Stories (локальные картинки остаются моками)
    func fetchStories() async throws -> [Story] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return [
            .init(imageName: "stories1", isViewed: false),
            .init(imageName: "stories2", isViewed: false),
            .init(imageName: "stories3", isViewed: false),
            .init(imageName: "stories4", isViewed: false),
        ]
    }

    // MARK: - Города (из справочника /stations_list)
    func fetchCities(matching query: String) async throws -> [City] {
        let all = try await loadStationsCatalog()
        var names = Set<String>()
        for country in all.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    if let title = settlement.title { names.insert(title) }
                }
            }
        }
        let allCities = names.sorted()
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return allCities.map { City(name: $0) } }
        return allCities.filter { $0.localizedCaseInsensitiveContains(q) }
                        .map { City(name: $0) }
    }

    // MARK: - Станции по городу (из справочника /stations_list)
    func fetchStations(city: String, matching query: String) async throws -> [String] {
        try Task.checkCancellation()
        let all = try await loadStationsCatalog()
        let key = normalize(city)
        var list: [String] = []
        for country in all.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    if let sTitle = settlement.title, normalize(sTitle) == key {
                        for st in settlement.stations ?? [] {
                            if let name = st.title { list.append(name) }
                        }
                    }
                }
            }
        }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return list }
        return list.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    // MARK: - Поиск рейсов между станциями (/search)
    func fetchCarriers(from: String, to: String) async throws -> [Carrier] {
        let all = try await loadStationsCatalog()

        func stationCode(from composed: String) -> String? {
            // ожидаем формат "Город (Станция)"
            if let l = composed.firstIndex(of: "("), let r = composed.lastIndex(of: ")"), l < r {
                let name = composed[composed.index(after: l)..<r].trimmingCharacters(in: .whitespacesAndNewlines)
                for country in all.countries ?? [] {
                    for region in country.regions ?? [] {
                        if let s = (region.settlements ?? []).flatMap({ $0.stations ?? [] }).first(where: { $0.title == name }) {
                            return s.codes?.yandexCode ?? s.codes?.yandex ?? s.codes?.esr
                        }
                    }
                }
            }
            // fallback: полное совпадение по title
            for country in all.countries ?? [] {
                for region in country.regions ?? [] {
                    if let s = (region.settlements ?? []).flatMap({ $0.stations ?? [] }).first(where: { $0.title == composed }) {
                        return s.codes?.yandexCode ?? s.codes?.yandex ?? s.codes?.esr
                    }
                }
            }
            return nil
        }

        guard let fromCode = stationCode(from: from), let toCode = stationCode(from: to) else {
            return []
        }

        // сегодняшняя дата (UTC) в формате API
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.locale   = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())

        // Собираем запрос /search
        var comps = URLComponents(url: baseURL.appendingPathComponent("search/"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "apikey", value: apiKey),
            .init(name: "from", value: fromCode),
            .init(name: "to", value: toCode),
            .init(name: "date", value: today),
            .init(name: "transfers", value: "1"),
            .init(name: "lang", value: "ru_RU")
        ]
        let (data, response) = try await session.data(from: comps.url!)
        try ensureOK(response)
        let rsp = try decoder.decode(SearchResponse.self, from: data)

        let iso = ISO8601DateFormatter()
        func hhmm(_ s: String?) -> String {
            guard let s, let d = iso.date(from: s) else { return "--:--" }
            let f = DateFormatter()
            f.locale = Locale(identifier: "ru_RU")
            f.timeZone = .current
            f.dateFormat = "HH:mm"
            return f.string(from: d)
        }
        func dayMonth(_ s: String?) -> String {
            guard let s, let d = iso.date(from: s) else { return "" }
            let f = DateFormatter()
            f.locale = Locale(identifier: "ru_RU")
            f.timeZone = .current
            f.dateFormat = "d MMMM"
            return f.string(from: d)
        }

        return (rsp.segments ?? []).compactMap { seg in
            let dep = seg.departure
            let arr = seg.arrival
            let dur = seg.duration ?? 0
            let hours = max(0, dur / 3600)
            let mins  = max(0, (dur % 3600) / 60)

            let depHour: Int = {
                guard let s = dep, let d = iso.date(from: s) else { return 0 }
                return Calendar.current.component(.hour, from: d)
            }()
            let category: DepartureTime = {
                switch depHour {
                case 0..<6: return .night
                case 6..<12: return .morning
                case 12..<18: return .day
                default: return .evening
                }
            }()

            let logo = seg.thread?.carrier?.code ?? seg.thread?.carrier?.title ?? "carrier"
            let note: String? = (seg.hasTransfers ?? false) ? "С пересадкой" : nil

            return Carrier(
                logo: logo,
                date: dayMonth(dep),
                transferNote: note,
                departure: hhmm(dep),
                duration: hours > 0 ? "\(hours) ч \(mins) м" : "\(mins) м",
                arrival: hhmm(arr),
                departureTimeCategory: category
            )
        }
    }

    // MARK: - Детали перевозчика (при желании можно вызвать /carrier)
    func carrierDetails(for name: String) async throws -> CarrierDetails {
        // Пока простой маппинг, реальный вызов можно добавить по коду перевозчика
        CarrierDetails(name: name, logoImageName: "carrier", email: nil, phone: nil)
    }
}

// MARK: - Вспомогательные модели под API (минимальные, только нужные поля)
private struct StationsListResponse: Decodable {
    let countries: [Country]?
    struct Country: Decodable { let regions: [Region]? }
    struct Region: Decodable { let settlements: [Settlement]? }
    struct Settlement: Decodable {
        let title: String?
        let stations: [Station]?
    }
    struct Station: Decodable {
        let title: String?
        let codes: Codes?
    }
    struct Codes: Decodable {
        let yandexCode: String?   // convertFromSnakeCase позволит распознать yandex_code
        let yandex: String?
        let esr: String?
    }
}

private struct SearchResponse: Decodable {
    let segments: [Segment]?
    struct Segment: Decodable {
        let departure: String?
        let arrival: String?
        let duration: Int?
        let hasTransfers: Bool?
        let thread: ThreadInfo?
    }
    struct ThreadInfo: Decodable {
        let carrier: CarrierInfo?
    }
    struct CarrierInfo: Decodable {
        // бывает code как строка или как число, поэтому оставим строку
        let code: String?
        let title: String?
    }
}

// MARK: - Вспомогательные
private extension NetworkClient {
    func ensureOK(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func loadStationsCatalog() async throws -> StationsListResponse {
        if let cached = stationsCatalogCache { return cached }
        var comps = URLComponents(url: baseURL.appendingPathComponent("stations_list/"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "apikey", value: apiKey),
            .init(name: "lang", value: "ru_RU")
            // Можно добавить transport_types=train если нужно фильтровать
        ]
        let (data, response) = try await session.data(from: comps.url!)
        try ensureOK(response)
        let parsed = try decoder.decode(StationsListResponse.self, from: data)
        stationsCatalogCache = parsed
        return parsed
    }

    /// Нормализация русских названий (регистр/диакритика/дефисы/пробелы/ё)
    func normalize(_ s: String) -> String {
        let lowered = s
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "ru_RU"))
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "ё", with: "е")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return lowered.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }
}
