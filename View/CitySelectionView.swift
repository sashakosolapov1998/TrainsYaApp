//
//  CitySelectionView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct CitySelectionView: View {
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private static let cities = [
        "Москва", "Санкт Петербург", "Сочи", "Горный воздух",
        "Краснодар", "Казань", "Омск"
    ]

    private var filteredCities: [String] {
        searchText.isEmpty ? Self.cities : Self.cities.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            if filteredCities.isEmpty {
                VStack(spacing: 0) {
                    Spacer().frame(height: 176)
                    Text("Город не найден")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.trainsBlack)
                        .frame(maxWidth: .infinity)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredCities, id: \.self) { city in
                    Button {
                        onSelect(city)
                    } label: {
                        HStack {
                            Text(city)
                                .foregroundColor(.trainsBlack)
                                .padding(.vertical, 10)
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
            prompt: "Введите запрос"
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.trainsBlack)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Выбор города")
                    .font(.headline)
                    .foregroundColor(.trainsBlack)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CitySelectionView { city in
        print("Selected city: \(city)")
    }
}
