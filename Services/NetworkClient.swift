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
    // Быстрый индекс: нормализованное имя станции → код станции
    private var stationIndexByTitle: [String: String] = [:]

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
            // Попробуем извлечь имя из формата "Город (Станция)"
            if let l = composed.firstIndex(of: "("), let r = composed.lastIndex(of: ")"), l < r {
                let stationName = composed[composed.index(after: l)..<r].trimmingCharacters(in: .whitespacesAndNewlines)
                let key = normalize(String(stationName))
                if let code = stationIndexByTitle[key] { return code }
            }
            // Если строка пришла без скобок — возможно это уже чистое имя станции
            let directKey = normalize(composed)
            if let code = stationIndexByTitle[directKey] { return code }
            return nil
        }

        let fromCode = stationCode(from: from)
        let toCode   = stationCode(from: to)
        print("🔎 [Search] input from=\(from), to=\(to)")
        print("🔎 [Search] resolved codes from=\(fromCode ?? "nil"), to=\(toCode ?? "nil")")
        guard let fromCode, let toCode else {
            print("⛔️ [Search] one or both station codes not found — aborting request")
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
            .init(name: "transfers", value: "0"),
            .init(name: "transport_types", value: "train,suburban"),
            .init(name: "lang", value: "ru_RU"),
            .init(name: "format", value: "json")
        ]
        if let url = comps.url { print("🌐 [Search] URL =", url.absoluteString) }
        let (data, response) = try await session.data(from: comps.url!)
        if let http = response as? HTTPURLResponse {
            print("🛣️ [Search] status =", http.statusCode)
        }
        try ensureOK(response)

        do {
            let rsp = try decoder.decode(SearchResponse.self, from: data)
            let count = rsp.segments?.count ?? 0
            print("📦 [Search] segments count =", count)
            if count == 0, let s = String(data: data, encoding: .utf8) {
                print("🧪 [Search] raw body (truncated):", s.prefix(800))
            }

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

            let segments = rsp.segments ?? []
            let result = segments.map { seg in
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

                // carrier code may come as string or int
                let codeInt: Int? = {
                    guard let c = seg.thread?.carrier?.code else { return nil }
                    switch c {
                    case .int(let i): return i
                    case .string(let s): return Int(s)
                    }
                }()

                let title = seg.thread?.carrier?.title ?? seg.thread?.number ?? "Перевозчик"
                let logoName  = carrierLogoName(from: codeInt)
                let note: String? = (seg.hasTransfers ?? false) ? "С пересадкой" : nil

                let logoURL: URL? = {
                    if let s = seg.thread?.carrier?.logo, let u = URL(string: s) { return u }
                    if let s = seg.thread?.carrier?.logoSvg, let u = URL(string: s) { return u }
                    return nil
                }()

                // extra carrier meta straight from /search
                let carrierURL: URL? = {
                    if let s = seg.thread?.carrier?.url, let u = URL(string: s) { return u }
                    return nil
                }()
                let carrierEmail = seg.thread?.carrier?.email
                let carrierPhone = seg.thread?.carrier?.phone
                let carrierAddress = seg.thread?.carrier?.address
                let carrierContacts = seg.thread?.carrier?.contacts

                return Carrier(
                    logo: logoName,
                    logoURL: logoURL,
                    code: codeInt,
                    title: title,
                    carrierURL: carrierURL,
                    carrierAddress: carrierAddress,
                    carrierPhone: carrierPhone,
                    carrierEmail: carrierEmail,
                    carrierContacts: carrierContacts,
                    date: dayMonth(dep),
                    transferNote: note,
                    departure: hhmm(dep),
                    duration: hours > 0 ? "\(hours) ч \(mins) м" : "\(mins) м",
                    arrival: hhmm(arr),
                    departureTimeCategory: category
                )
            }
            return result
        } catch {
            if let s = String(data: data, encoding: .utf8) {
                print("💥 [Search] decode error =", error, "\n🔸 raw body:", s.prefix(1200))
            } else {
                print("💥 [Search] decode error =", error, " (body not UTF-8)")
            }
            throw error
        }
    }

// MARK: - Детали перевозчика
/// Вариант для обратной совместимости: по имени пока возвращаем stub.
/// Рекомендуется вызывать `carrierDetails(code:)`, чтобы тянуть данные из API.
func carrierDetails(for name: String) async throws -> CarrierDetails {
    return CarrierDetails(
        name: name,
        logoURL: nil,
        email: nil,
        phone: nil,
        code: nil
    )
}

/// Реальные детали перевозчика по коду из API Яндекса.
func carrierDetails(code: String) async throws -> CarrierDetails {
    var comps = URLComponents(url: baseURL.appendingPathComponent("carrier/"), resolvingAgainstBaseURL: false)!
    comps.queryItems = [
        .init(name: "apikey", value: apiKey),
        .init(name: "code", value: code),
        .init(name: "format", value: "json")
    ]
    let (data, response) = try await session.data(from: comps.url!)
    try ensureOK(response)

    let info = try decoder.decode(CarrierDetailsResponse.self, from: data)
    let url: URL? = {
        if let s = info.logo, let u = URL(string: s) { return u }
        if let s = info.logoSvg, let u = URL(string: s) { return u }
        return nil
    }()
    let codeInt: Int? = {
        guard let c = info.code else { return nil }
        return Int(c)
    }()

    return CarrierDetails(
        name: info.title ?? "Перевозчик",
        logoURL: url,
        email: info.email,
        phone: info.phone,
        code: codeInt
    )
}

/// Перегрузка для удобства, если код приходит числом
func carrierDetails(code: Int) async throws -> CarrierDetails {
    try await carrierDetails(code: String(code))
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
    enum StringOrInt: Decodable {
        case string(String)
        case int(Int)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let i = try? container.decode(Int.self) {
                self = .int(i)
            } else if let s = try? container.decode(String.self) {
                self = .string(s)
            } else {
                throw DecodingError.typeMismatch(String.self, .init(codingPath: decoder.codingPath, debugDescription: "Expected String or Int for StringOrInt"))
            }
        }

        var stringValue: String {
            switch self {
            case .string(let s): return s
            case .int(let i): return String(i)
            }
        }
    }
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
        let number: String?
    }
    struct CarrierInfo: Decodable {
        // бывает code как строка или как число, поэтому оставим строку
        let code: StringOrInt?
        let title: String?
        let logo: String?
        let logoSvg: String?
        // дополнительные поля, которые иногда приходят в /search
        let url: String?
        let email: String?
        let phone: String?
        let address: String?
        let contacts: String?
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
        // Построим индекс станций: по нормализованному названию найдём код
        var idx: [String: String] = [:]
        for country in parsed.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    for st in settlement.stations ?? [] {
                        if let name = st.title {
                            let key = normalize(name)
                            if let code = st.codes?.yandexCode ?? st.codes?.yandex ?? st.codes?.esr, !key.isEmpty, !code.isEmpty {
                                idx[key] = code
                            }
                        }
                    }
                }
            }
        }
        self.stationIndexByTitle = idx
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

    /// Возвращаем имя ассета с логотипом перевозчика по коду Яндекса (Int).
    /// Если ассета нет — возвращаем дефолтную картинку "carrier".
    func carrierLogoName(from code: Int?) -> String {
        guard let n = code else { return "carrier" }
        switch n {
        // Примеры: заполняй, когда добавишь ассеты в каталоге.
        // case 129: return "tverskoy"   // Тверской Экспресс
        // case 2:   return "rzd"        // РЖД
        default:
            return "carrier"
        }
    }
}

private struct CarrierDetailsResponse: Decodable {
    let title: String?
    let code: String?
    let url: String?
    let email: String?
    let phone: String?
    let logo: String?
    let logoSvg: String?
}
