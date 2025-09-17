//
//  StationSelectionViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 13/9/25.
//

import Foundation

// MARK: - ViewModel
@MainActor
final class StationSelectionViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var stations: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let city: String
    private let client: NetworkClient
    private var searchTask: Task<Void, Never>? = nil

    init(city: String, client: NetworkClient = .shared) {
        self.city = city
        self.client = client
    }

    deinit { searchTask?.cancel() }

    func onAppear() {
        print("⚙️ [StationSelectionViewModel] onAppear, city = \(city)")
        if stations.isEmpty {
            searchImmediately(query: "")
        }
    }

    func setSearchText(_ text: String) {
        searchText = text
        debounceSearch(query: text)
    }

    private func debounceSearch(query: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: 250_000_000)
                if Task.isCancelled { return }
                await self.search(query: query)
            } catch { }
        }
    }

    private func searchImmediately(query: String) {
        searchTask?.cancel()
        isLoading = true
        print("🔍 [StationSelectionViewModel] immediate search, query = \(query)")
        errorMessage = nil
        searchTask = Task { [weak self] in
        await self?.search(query: query)
        }
    }

    private func search(query: String) async {
        print("📡 [StationSelectionViewModel] start search with query = \(query), city = \(city)")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let list = try await client.fetchStations(city: city, matching: query)
            try Task.checkCancellation()
            self.stations = list
            print("✅ [StationSelectionViewModel] success, stations = \(list)")
        } catch is CancellationError {
            return
        } catch {
            print("❌ [StationSelectionViewModel] error: \(error)")
            self.stations = []
            if let urlErr = error as? URLError,
               [.notConnectedToInternet, .timedOut, .networkConnectionLost,
                .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed].contains(urlErr.code) {
                self.errorMessage = "Нет интернета"
            } else {
                self.errorMessage = "Не удалось загрузить станции"
            }
        }
    }
}
