//
//  CarrierInfoViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 14/9/25.
//

import Foundation

@MainActor
final class CarrierInfoViewModel: ObservableObject {
    @Published var name: String
    @Published var logoURL: URL?
    @Published var email: String?
    @Published var phone: String?

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let client: NetworkClient
    private let lookupName: String
    private let lookupCode: Int?

    init(initial: CarrierDetails, code: Int? = nil, logoURL: URL? = nil, client: NetworkClient = .shared) {
        self.client = client
        self.lookupName = initial.name
        self.lookupCode = code ?? initial.code
        self.name = initial.name
        self.logoURL = logoURL ?? initial.logoURL
        self.email = initial.email
        self.phone = initial.phone
        
        }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fresh: CarrierDetails
            if let code = lookupCode {
                fresh = try await client.carrierDetails(code: String(code))
            } else {
               
                fresh = try await client.carrierDetails(for: lookupName)
            }

            let trimmed = fresh.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed == "Перевозчик" {
            } else {
                self.name = fresh.name
            }
            
            if let newLogo = fresh.logoURL { self.logoURL = newLogo }

            if let newEmail = fresh.email, !newEmail.isEmpty { self.email = newEmail }
            if let newPhone = fresh.phone, !newPhone.isEmpty { self.phone = newPhone }

        } catch {
            self.errorMessage = "Не удалось загрузить информацию о перевозчике"

        }
    }
}
