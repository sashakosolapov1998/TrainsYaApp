//
//  CarrierListViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 13/9/25.
//


import Foundation

// MARK: - Модель рейса
struct Carrier: Identifiable, Sendable {
    let id = UUID()
    let logo: String
    let logoURL: URL?
    let code: Int?
    let title: String
    
    // доп поля из API
        let carrierURL: URL?
        let carrierAddress: String?
        let carrierPhone: String?
        let carrierEmail: String?
        let carrierContacts: String?
    
    let date: String
    let transferNote: String?
    let departure: String
    let duration: String
    let arrival: String
    let departureTimeCategory: DepartureTime
}

@MainActor
final class CarrierListViewModel: ObservableObject {

    let fromText: String
    let toText: String

    @Published var showFilters = false
    @Published var allCarriers: [Carrier] = []
    @Published var filteredCarriers: [Carrier] = []

    @Published var currentSelectedTimes: Set<DepartureTime> = []
    @Published var currentShowTransfers: Bool?

    @Published var selectedCarrier: CarrierDetails?
    @Published var selectedCarrierCode: Int? = nil

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let client: NetworkClient

    init(fromText: String, toText: String, client: NetworkClient = .shared) {
        self.fromText = fromText
        self.toText = toText
        self.client = client
    }

    // MARK: - Жизненный цикл
    func onAppear() {
        if allCarriers.isEmpty {
            Task { await loadCarriers() }
        } else {
            applyFilters(times: currentSelectedTimes, transfers: currentShowTransfers)
        }
    }

    // MARK: - Действия UI
    func openFilters() { showFilters = true }

    func applyFilters(times: Set<DepartureTime>, transfers: Bool?) {
        currentSelectedTimes = times
        currentShowTransfers = transfers

        filteredCarriers = allCarriers.filter { carrier in
            let timeOK = times.isEmpty || times.contains(carrier.departureTimeCategory)
            let transfersOK = transfers == nil || (transfers! == (carrier.transferNote != nil))
            return timeOK && transfersOK
        }
    }


    func didSelectCarrier(id: UUID) {
        guard let carrier = filteredCarriers.first(where: { $0.id == id }) else {
            selectedCarrier = CarrierDetails(name: "Перевозчик", logoURL: nil, email: nil, phone: nil, code: nil)
            selectedCarrierCode = nil
            return
        }
    
        selectedCarrier = CarrierDetails(
            name: carrier.title,
            logoURL: carrier.logoURL,
            email: carrier.carrierEmail,
            phone: carrier.carrierPhone,
            code: carrier.code
        )
        selectedCarrierCode = carrier.code
    }

    func didSelectCarrier(withLogo logo: String) {
      
        for carrier in filteredCarriers {
        }
      
        guard let carrier = filteredCarriers.first(where: { $0.logo == logo || $0.title == logo }) else {
            
            selectedCarrier = CarrierDetails(name: "Перевозчик", logoURL: nil, email: nil, phone: nil, code: nil)
            selectedCarrierCode = nil
            return
        }

        selectedCarrier = CarrierDetails(
            name: carrier.title,
            logoURL: carrier.logoURL,
            email: carrier.carrierEmail,
            phone: carrier.carrierPhone,
            code: carrier.code
        )
    
        selectedCarrierCode = carrier.code
    }

    // MARK: - Загрузка
    private func loadCarriers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let list = try await client.fetchCarriers(from: fromText, to: toText)
            self.allCarriers = list
            self.filteredCarriers = list
            if !currentSelectedTimes.isEmpty || currentShowTransfers != nil {
                applyFilters(times: currentSelectedTimes, transfers: currentShowTransfers)
            }
        } catch {
            self.allCarriers = []
            self.filteredCarriers = []
            self.errorMessage = "Не удалось загрузить рейсы. Повторите попытку."
        }
    }

    /* // MARK: - Маппер логотип → карточка
    private func details(for logo: String) -> CarrierDetails {
        switch logo {
        case "rzd":
            return CarrierDetails(
                name: "ОАО «РЖД»",
                logoImageName: "rzdHighRes",
                email: "i.lozgkina@yandex.ru",
                phone: "+7 (904) 329-27-71"
            )
        case "fgk":
            return CarrierDetails(name: "ФГК", logoImageName: "fgk", email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71")
        case "uralLogistics":
            return CarrierDetails(name: "Урал логистика", logoImageName: "uralLogistics", email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71")
        default:
            return CarrierDetails(name: "Перевозчик", logoImageName: logo, email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71")
        }
    }
    */
}
