//
//  CarrierListView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI
// MARK: - Models
struct Carrier: Identifiable {
    let id = UUID()
    let logo: String
    let date: String
    let transferNote: String?
    let departure: String
    let duration: String
    let arrival: String
    let departureTimeCategory: DepartureTime
}

// MARK: - Views
struct CarrierListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFilters = false

    @State private var allCarriers: [Carrier] = [
        Carrier(logo: "rzd",  date: "14 января", transferNote: "С пересадкой в Костроме", departure: "22:30", duration: "20 часов", arrival: "08:15", departureTimeCategory: .evening),
        Carrier(logo: "fgk",  date: "15 января", transferNote: nil,                           departure: "01:15", duration: "9 часов",  arrival: "09:00", departureTimeCategory: .night),
        Carrier(logo: "ural", date: "16 января", transferNote: nil,                           departure: "12:30", duration: "9 часов",  arrival: "21:00", departureTimeCategory: .day),
        Carrier(logo: "rzd",  date: "17 января", transferNote: "С пересадкой в Костроме",     departure: "22:30", duration: "20 часов", arrival: "08:15", departureTimeCategory: .evening),
        Carrier(logo: "uralLogistics", date: "16 января", transferNote: nil,                           departure: "12:30", duration: "9 часов",  arrival: "21:00", departureTimeCategory: .day)
    ]

    @State private var filteredCarriers: [Carrier] = []

    @State private var currentSelectedTimes: Set<DepartureTime> = []
    @State private var currentShowTransfers: Bool?

    let fromText: String
    let toText: String

    private var hasActiveFilters: Bool { !currentSelectedTimes.isEmpty || currentShowTransfers != nil }

    var body: some View {
        VStack(spacing: 0) {

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.trainsBlack)
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .padding(.bottom, 16)

                (Text(fromText)
                    + Text(" → ")
                    + Text(toText))
                .foregroundColor(.trainsBlack)
                .font(.system(size: 24, weight: .bold))
            }
            .padding()

            ScrollView {
                VStack(spacing: 8) {
                    if filteredCarriers.isEmpty {
                        Text("Вариантов нет")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.trainsBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 230)
                    } else {
                        ForEach(filteredCarriers) { c in
                            CarrierCardView(
                                logo: c.logo,
                                date: c.date,
                                transferNote: c.transferNote,
                                departure: c.departure,
                                duration: c.duration,
                                arrival: c.arrival
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }

            Button(action: {
                showFilters = true
            }) {
                HStack(spacing: 6) {
                    Text("Уточнить время")
                        .foregroundColor(.white)
                        .font(.headline)

                    if hasActiveFilters {
                        Circle()
                            .fill(Color.trainsRed)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .fullScreenCover(isPresented: $showFilters) {
                FiltersView(
                    initialSelectedTimes: currentSelectedTimes,
                    initialShowTransfers: currentShowTransfers
                ) { selectedTimes, showTransfers in
                    currentSelectedTimes = selectedTimes
                    currentShowTransfers = showTransfers
                    applyFilters(times: selectedTimes, transfers: showTransfers)
                }
            }
        }
        .background(Color.trainsWhite)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            filteredCarriers = allCarriers

            if hasActiveFilters {
                applyFilters(times: currentSelectedTimes, transfers: currentShowTransfers)
            }
        }
    }

    // MARK: - Фильтрация
    private func applyFilters(times: Set<DepartureTime>, transfers: Bool?) {
        filteredCarriers = allCarriers.filter { carrier in
            let timeOK = times.isEmpty || times.contains(carrier.departureTimeCategory)
            let transfersOK: Bool = {
                guard let t = transfers else { return true }
                return t == (carrier.transferNote != nil)
            }()
            return timeOK && transfersOK
        }
    }
}

// MARK: - Ячейка рейса
struct CarrierCardView: View {
    let logo: String
    let date: String
    let transferNote: String?
    let departure: String
    let duration: String
    let arrival: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(logo)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(logoName(for: logo))
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                    if let note = transferNote {
                        Text(note)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 16)

                Spacer()

                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(.bottom, 25)
            }

            HStack {
                Text(departure)
                    .font(.system(size: 17))

                ZStack {
                    Capsule()
                        .frame(height: 1)
                        .foregroundColor(.gray)

                    Text(duration)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .padding(.horizontal, 4)
                        .background(Color.trainsLightGray)
                }
                .frame(height: 20)
                .padding(.horizontal, 8)

                Text(arrival)
                    .font(.system(size: 17))
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(Color.trainsLightGray)
        .cornerRadius(24)
    }

    private func logoName(for imageName: String) -> String {
        switch imageName {
        case "rzd": return "РЖД"
        case "fgk": return "ФГК"
        case "ural": return "Урал логистика"
        case "uralLogistics": return "Урал логистика"
        default: return "Перевозчик"
        }
    }
}

// MARK: - Preview
#Preview {
    CarrierListView(
        fromText: "Москва (Ярославский вокзал)",
        toText: "Санкт-Петербург (Балтийский вокзал)"
    )
}
