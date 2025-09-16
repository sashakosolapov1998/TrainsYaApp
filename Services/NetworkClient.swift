//
//  NetworkClient.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 15/9/25.
//


//
//  NetworkClient.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 15/9/25.
//

import Foundation

/// Единый сетевой клиент приложения.
/// Сейчас возвращает те же мок-данные, что и локальные Mock*API,
/// но оформлен как actor, чтобы обеспечить безопасный доступ из разных задач.
actor NetworkClient {
    // MARK: - Singleton для простоты DI
    static let shared = NetworkClient()

    // Если понадобится реальная сеть:
    // private let session: URLSession
    // private let baseURL: URL
    // private let apiKey: String
    // init(session: URLSession = .shared, baseURL: URL, apiKey: String) { ... }

    // MARK: - Stories
    func fetchStories() async throws -> [Story] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return [
            .init(imageName: "stories1", isViewed: false),
            .init(imageName: "stories2", isViewed: false),
            .init(imageName: "stories3", isViewed: false),
            .init(imageName: "stories4", isViewed: false),
        ]
    }

    // MARK: - Cities
    func fetchCities(matching query: String) async throws -> [City] {
        try await Task.sleep(nanoseconds: 180_000_000)
        try Task.checkCancellation()

        let all: [City] = [
            .init(name: "Москва"),
            .init(name: "Санкт Петербург"),
            .init(name: "Сочи"),
            .init(name: "Горный воздух"),
            .init(name: "Краснодар"),
            .init(name: "Казань"),
            .init(name: "Омск"),
        ]
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    // MARK: - Stations
    func fetchStations(city: String, matching query: String) async throws -> [String] {
        try await Task.sleep(nanoseconds: 150_000_000)
        try Task.checkCancellation()

        let data: [String: [String]] = [
            "Москва": ["Киевский вокзал", "Курский вокзал", "Ярославский вокзал", "Белорусский вокзал", "Савеловский вокзал", "Ленинградский вокзал"],
            "Санкт Петербург": ["Ладожский", "Московский"],
            "Казань": ["Казань-Пассажирская", "Казань-2"],
            "Сочи": ["Сочи-Пассажирский"],
            "Горный воздух": ["Центральная"],
            "Краснодар": ["Краснодар-1", "Краснодар-2"],
            "Омск": ["Омск-Пассажирский"],
        ]
        let all = data[city] ?? []
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    // MARK: - Carriers list
    func fetchCarriers(from: String, to: String) async throws -> [Carrier] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return [
            Carrier(logo: "rzd",  date: "14 января", transferNote: "С пересадкой в Костроме", departure: "22:30", duration: "20 часов", arrival: "08:15", departureTimeCategory: .evening),
            Carrier(logo: "fgk",  date: "15 января", transferNote: nil,                           departure: "01:15", duration: "9 часов",  arrival: "09:00", departureTimeCategory: .night),
            Carrier(logo: "uralLogistics", date: "16 января", transferNote: nil,                  departure: "12:30", duration: "9 часов",  arrival: "21:00", departureTimeCategory: .day),
            Carrier(logo: "rzd",  date: "17 января", transferNote: "С пересадкой в Костроме",     departure: "22:30", duration: "20 часов", arrival: "08:15", departureTimeCategory: .evening),
            Carrier(logo: "uralLogistics", date: "16 января", transferNote: nil,                  departure: "12:30", duration: "9 часов",  arrival: "21:00", departureTimeCategory: .day),
        ]
    }

    // MARK: - Carrier details
    func carrierDetails(for name: String) async throws -> CarrierDetails {
        try await Task.sleep(nanoseconds: 160_000_000)
        switch name {
        case "ОАО «РЖД»":
            return CarrierDetails(name: name, logoImageName: "rzdHighRes",
                                  email: "info@rzd.ru", phone: "+7 (800) 775-00-00")
        case "ФГК":
            return CarrierDetails(name: name, logoImageName: "fgk",
                                  email: "support@fgk.ru", phone: "+7 (495) 123-45-67")
        case "Урал логистика":
            return CarrierDetails(name: name, logoImageName: "uralLogistics",
                                  email: "support@fgk.ru", phone: "+7 (495) 123-45-67")
        default:
            return CarrierDetails(name: name, logoImageName: "carrier",
                                  email: nil, phone: nil)
        }
    }
}
