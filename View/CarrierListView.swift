//
//  CarrierListView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI
// MARK: - Views
struct CarrierListView: View {
    @Environment(\.dismiss) private var dismiss

    let fromText: String
    let toText: String

    @StateObject private var vm: CarrierListViewModel

    init(fromText: String, toText: String) {
        self.fromText = fromText
        self.toText = toText
        _vm = StateObject(wrappedValue: CarrierListViewModel(fromText: fromText, toText: toText))
    }

    private var hasActiveFilters: Bool { !vm.currentSelectedTimes.isEmpty || vm.currentShowTransfers != nil }

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

                (Text(vm.fromText)
                    + Text(" → ")
                    + Text(vm.toText))
                .foregroundColor(.trainsBlack)
                .font(.system(size: 24, weight: .bold))
            }
            .padding()

            ScrollView {
                VStack(spacing: 8) {
                    if vm.filteredCarriers.isEmpty {
                        Text("Вариантов нет")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.trainsBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 230)
                    } else {
                        ForEach(vm.filteredCarriers) { c in
                            CarrierCardView(
                                logo: c.logo,
                                date: c.date,
                                transferNote: c.transferNote,
                                departure: c.departure,
                                duration: c.duration,
                                arrival: c.arrival,
                                onCarrierTap: { vm.didSelectCarrier(withLogo: c.logo) }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }

            Button(action: {
                vm.openFilters()
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
            .fullScreenCover(isPresented: $vm.showFilters) {
                FiltersView(
                    initialSelectedTimes: vm.currentSelectedTimes,
                    initialShowTransfers: vm.currentShowTransfers
                ) { selectedTimes, showTransfers in
                    vm.applyFilters(times: selectedTimes, transfers: showTransfers)
                }
            }
        }
        .background(Color.trainsWhite)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $vm.selectedCarrier) { carrier in
            CarrierDetailView(carrier: carrier)
        }
        .task { vm.onAppear() }
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
    let onCarrierTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(logo)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 16)
                    .onTapGesture { onCarrierTap() }

                VStack(alignment: .leading, spacing: 2) {
                    Text(logoName(for: logo))
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                        .onTapGesture { onCarrierTap() }
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
