//
//  SettingsViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 13/9/25.
//
import Foundation

// MARK: - Storage (Model)
protocol SettingsStore {
   var isDarkMode: Bool { get set }
}

final class UserDefaultsSettingsStore: SettingsStore {
    private let key = "isDarkMode"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [key: false])
    }

    var isDarkMode: Bool {
        get { defaults.bool(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}

// MARK: - Routing
enum SettingsRoute: Hashable {
    case userAgreement
}

// MARK: - ViewModel
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool
    @Published var route: SettingsRoute? = nil

    private var store: SettingsStore

    init(store: SettingsStore = UserDefaultsSettingsStore()) {
        self.store = store
        self.isDarkMode = store.isDarkMode
    }

    func toggleDarkMode(_ value: Bool) {
        isDarkMode = value
        store.isDarkMode = value
    }

    func openAgreement() { route = .userAgreement }
    func closeRoute() { route = nil }
}

