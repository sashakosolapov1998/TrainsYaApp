//
//  FiltersViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 14/9/25.
//


import Foundation

@MainActor
final class FiltersViewModel: ObservableObject {
    @Published var selectedTimes: Set<DepartureTime>
    @Published var showTransfers: Bool?

    var isAnyFilterSelected: Bool {
        !selectedTimes.isEmpty || showTransfers != nil
    }

    init(selectedTimes: Set<DepartureTime> = [], showTransfers: Bool? = nil) {
        self.selectedTimes = selectedTimes
        self.showTransfers = showTransfers
    }

    func toggleTime(_ time: DepartureTime) {
        if selectedTimes.contains(time) {
            selectedTimes.remove(time)
        } else {
            selectedTimes.insert(time)
        }
    }

    func setTransfers(_ value: Bool) {
        showTransfers = value
    }
}
