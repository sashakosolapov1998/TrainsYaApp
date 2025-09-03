//
//  StationSelectionView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//
import SwiftUI

// MARK: - Views
struct StationSelectionView: View {
    let city: String
    let onSelect: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    private static let stationsByCity: [String: [String]] = [
        "Москва": ["Киевский вокзал", "Курский вокзал", "Ярославский вокзал", "Белорусский вокзал", "Савеловский вокзал", "Ленинградский вокзал"],
        "Санкт Петербург": ["Ладожский", "Московский"],
        "Казань": ["Казань-Пассажирская", "Казань-2"],
        "Сочи": ["Сочи-Пассажирский"],
        "Горный воздух": ["Центральная"],
        "Краснодар": ["Краснодар-1", "Краснодар-2"],
        "Омск": ["Омск-Пассажирский"]
    ]
    
    private var stations: [String] {
        Self.stationsByCity[city] ?? []
    }
    
    private var filteredStations: [String] {
        return searchText.isEmpty ? stations : stations.filter { $0.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            if filteredStations.isEmpty {
                VStack(spacing: 0) {
                    Spacer().frame(height: 100)
                    Text("Станция не найдена")
                        .font(.headline)
                        .foregroundColor(.trainsBlack)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredStations, id: \.self) { station in
                    Button {
                        onSelect(station)
                    } label: {
                        HStack {
                            Text(station)
                                .foregroundColor(.trainsBlack)
                                .padding(.vertical, 10)
                                .font(.system(size: 17))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.trainsBlack)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .background(Color.clear)
        .scrollContentBackground(.hidden)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Введите станцию"
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.trainsBlack)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Выбор станции")
                    .font(.headline)
                    .foregroundColor(.trainsBlack)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StationSelectionView(city: "Москва") { selectedStation in
        print("Selected station: \(selectedStation)")
    }
}
