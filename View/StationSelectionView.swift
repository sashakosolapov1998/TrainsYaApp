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
    @StateObject private var vm: StationSelectionViewModel

    init(city: String, onSelect: @escaping (String) -> Void) {
        self.city = city
        self.onSelect = onSelect
        _vm = StateObject(wrappedValue: StationSelectionViewModel(city: city))
    }
    
    var body: some View {
        List {
            if vm.isLoading {
                VStack(spacing: 16) {
                    Spacer().frame(height: 100)
                    ProgressView()
                    Text("Загрузка...")
                        .foregroundColor(.trainsBlack)
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if let message = vm.errorMessage {
                VStack(spacing: 12) {
                    Spacer().frame(height: 100)
                    Text(message)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.trainsBlack)
                    Button("Повторить") {
                        vm.setSearchText(vm.searchText)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if vm.stations.isEmpty {
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
                ForEach(vm.stations, id: \.self) { station in
                    Button {
                        onSelect(station)
                        dismiss()
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
            text: Binding(
                get: { vm.searchText },
                set: { vm.setSearchText($0) }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Введите станцию"
        )
        .task { vm.onAppear() }
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
