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
    @StateObject private var vm = CitySelectionViewModel()

    var body: some View {
        List {
            if vm.isLoading {
                VStack(spacing: 16) {
                    Spacer().frame(height: 160)
                    ProgressView()
                    Text("Загрузка...")
                        .foregroundColor(.trainsBlack)
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if let message = vm.errorMessage {
                VStack(spacing: 12) {
                    Spacer().frame(height: 160)
                    Text(message)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.trainsBlack)
                    Button("Повторить") {
                        // повторный запрос с текущим текстом
                        vm.setSearchText(vm.searchText)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if vm.cities.isEmpty {
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
                ForEach(vm.cities) { city in
                    Button {
                        onSelect(city.name)
                        dismiss()
                    } label: {
                        HStack {
                            Text(city.name)
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
            text: Binding(
                get: { vm.searchText },
                set: { vm.setSearchText($0) }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Введите запрос"
        )
        .task { vm.onAppear() }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
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
