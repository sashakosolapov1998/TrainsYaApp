//
//  CarrierInfoViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 14/9/25.
//

import Foundation

@MainActor
final class CarrierDetailViewModel: ObservableObject {
    @Published var name: String
    @Published var logoImageName: String
    @Published var email: String?
    @Published var phone: String?

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let client: NetworkClient
    private let lookupKey: String

    init(initial: CarrierDetails, client: NetworkClient = .shared) {
        self.client = client
        self.lookupKey = initial.name
        self.name = initial.name
        self.logoImageName = initial.logoImageName
        self.email = initial.email
        self.phone = initial.phone
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fresh = try await client.carrierDetails(for: lookupKey)
            self.name = fresh.name
            self.logoImageName = fresh.logoImageName
            self.email = fresh.email
            self.phone = fresh.phone
        } catch {
            self.errorMessage = "Не удалось загрузить информацию о перевозчике"
        }
    }
}
