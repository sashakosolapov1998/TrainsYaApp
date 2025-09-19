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
        
        print("🔵 CarrierInfoViewModel init:")
            print("   name = \(self.name)")
            print("   logoURL = \(String(describing: self.logoURL))")
            print("   email = \(String(describing: self.email))")
            print("   phone = \(String(describing: self.phone))")
            print("   code = \(String(describing: self.lookupCode))")
        }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fresh: CarrierDetails
            if let code = lookupCode {
                print("🌐 Запрашиваю carrierDetails по code = \(code)")
                fresh = try await client.carrierDetails(code: String(code))
            } else {
                print("🌐 Запрашиваю carrierDetails по name = \(lookupName)")
                fresh = try await client.carrierDetails(for: lookupName)
            }

            print("✅ Получен ответ:")
            print("   name = \(fresh.name)")
            print("   logoURL = \(String(describing: fresh.logoURL))")
            print("   email = \(String(describing: fresh.email))")
            print("   phone = \(String(describing: fresh.phone))")

            let trimmed = fresh.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed == "Перевозчик" {
                // Яндекс не вернул осмысленное название — оставляем предыдущее
                print("ℹ️ API вернул generic name, оставляю исходное: \(self.name)")
            } else {
                self.name = fresh.name
            }

            // Логотип используем, если пришёл URL; иначе оставляем прежний (из списка)
            if let newLogo = fresh.logoURL { self.logoURL = newLogo }

            // Контакты обновляем только если пришли непустые значения
            if let newEmail = fresh.email, !newEmail.isEmpty { self.email = newEmail }
            if let newPhone = fresh.phone, !newPhone.isEmpty { self.phone = newPhone }

            print("🟢 Обновил VM: name=\(self.name), logo=\(String(describing: self.logoURL)), email=\(String(describing: self.email)), phone=\(String(describing: self.phone))")
        } catch {
            self.errorMessage = "Не удалось загрузить информацию о перевозчике"
            print("❌ Ошибка загрузки carrierDetails: \(error)")
        }
    }
}
