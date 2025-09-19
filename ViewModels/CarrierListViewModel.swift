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

    /// Предпочтительный способ выбора: по уникальному `id` конкретной карточки
    func didSelectCarrier(id: UUID) {
        // Ищем ровно тот элемент, на который тапнули
        guard let carrier = filteredCarriers.first(where: { $0.id == id }) else {
            print("⚠️ didSelectCarrier(id:) — не нашли carrier по id \(id)")
            selectedCarrier = CarrierDetails(name: "Перевозчик", logoURL: nil, email: nil, phone: nil, code: nil)
            selectedCarrierCode = nil
            return
        }
        print("✅ Selected by id: \(carrier.title), code: \(String(describing: carrier.code))")
        selectedCarrier = CarrierDetails(
            name: carrier.title,
            logoURL: carrier.logoURL,
            email: nil,
            phone: nil,
            code: carrier.code
        )
        selectedCarrierCode = carrier.code
    }

    func didSelectCarrier(withLogo logo: String) {
        // ⚠️ УСТАРЕВШЕ: выбор по `logo` неоднозначен (несколько разных перевозчиков могут иметь один логотип).
        // Лучше использовать didSelectCarrier(id:), пробрасывая `carrier.id` из вью.
        print("⚠️ didSelectCarrier(withLogo:) используется — выбор может быть неверным. logo='\(logo)'")
        for carrier in filteredCarriers {
            print("• card: title=\(carrier.title), code=\(String(describing: carrier.code)), logo=\(carrier.logo)")
        }
        // Находим выбранный элемент в текущей выборке (по совпадению logo и title)
        guard let carrier = filteredCarriers.first(where: { $0.logo == logo || $0.title == logo }) else {
            // fallback — покажем заглушку
            selectedCarrier = CarrierDetails(name: "Перевозчик", logoURL: nil, email: nil, phone: nil, code: nil)
            selectedCarrierCode = nil
            return
        }
        print("Selected carrier: \(carrier.title), code: \(String(describing: carrier.code))")
        // Начальные данные для экрана (UI может сразу показать имя)
        selectedCarrier = CarrierDetails(
            name: carrier.title,
            logoURL: carrier.logoURL,
            email: nil,
            phone: nil,
            code: carrier.code
        )
        // Код перевозчика — чтобы CarrierDetailViewModel мог загрузить реальные данные из API
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
