//
//  HomeViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 13/9/25.
//

import Foundation
import SwiftUI

enum HomeRoute: Hashable, Sendable {
    case selectFromCity
    case selectFromStation(city: String)
    case selectToCity
    case selectToStation(city: String)
    case carriers
}

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Ввод/вывод (публичные данные экрана)
    @Published var fromText: String = ""
    @Published var toText: String = ""

    @Published var selectedFromCity: String = ""
    @Published var selectedToCity: String = ""

    @Published var route: HomeRoute? = nil

    @Published var stories: [Story] = []
    @Published var showStories: Bool = false
    @Published var currentStoryIndex: Int = 0

    // MARK: - Зависимости
    private let client: NetworkClient

    // MARK: - Инициализация
    init(client: NetworkClient = .shared) {
        self.client = client
    }

    // MARK: - Интенции (действия UI)

    func startSelectingFrom() {
        route = .selectFromCity
    }
    func startSelectingTo() {
        route = .selectToCity
    }

    func selectFromCity(_ city: String) {
        selectedFromCity = city
        // Отложим навигацию на следующий runloop, чтобы избежать "Update NavigationRequestObserver..."
        DispatchQueue.main.async { [weak self] in
            self?.route = .selectFromStation(city: city)
        }
    }

    func selectFromStation(_ station: String) {
        fromText = prettyStationTitle(city: selectedFromCity, stationTitle: station)
        route = nil
    }

    func selectToCity(_ city: String) {
        selectedToCity = city
        // Отложим навигацию на следующий runloop, чтобы избежать "Update NavigationRequestObserver..."
        DispatchQueue.main.async { [weak self] in
            self?.route = .selectToStation(city: city)
        }
    }

    func selectToStation(_ station: String) {
        toText = prettyStationTitle(city: selectedToCity, stationTitle: station)
        route = nil
    }

    func swapDirections() {
        swap(&fromText, &toText)
    }

    func searchCarriers() {
        guard !fromText.isEmpty, !toText.isEmpty else { return }
        route = .carriers
    }

    func closeRoute() { route = nil }

    func tapStory(at index: Int) {
        currentStoryIndex = index
        showStories = true
    }

    // MARK: - Загрузка данных
    func loadStories() async {
        do {
            let items = try await client.fetchStories()
            self.stories = items
        } catch {
            self.stories = []
        }
    }
}

private extension HomeViewModel {
    func prettyStationTitle(city: String, stationTitle: String) -> String {
        func norm(_ s: String) -> String {
            s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .init(identifier: "ru_RU"))
             .replacingOccurrences(of: "ё", with: "е")
             .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if norm(stationTitle).hasPrefix(norm(city)) {
            return stationTitle
        } else {
            return "\(city) (\(stationTitle))"
        }
    }
}
