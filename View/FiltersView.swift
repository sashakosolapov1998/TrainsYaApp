//
//  FiltersView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTimes: Set<DepartureTime>
    @State private var showTransfers: Bool?

    var onApply: ((Set<DepartureTime>, Bool?) -> Void)?

    init(
        initialSelectedTimes: Set<DepartureTime> = [],
        initialShowTransfers: Bool? = nil,
        onApply: ((Set<DepartureTime>, Bool?) -> Void)? = nil
    ) {
        _selectedTimes = State(initialValue: initialSelectedTimes)
        _showTransfers  = State(initialValue: initialShowTransfers)
        self.onApply    = onApply
    }

    private var isAnyFilterSelected: Bool {
        !selectedTimes.isEmpty || showTransfers != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.trainsBlack)
                        .imageScale(.large)
                }
                Spacer()
            }
            .padding(.bottom, 4)

            Text("Время отправления")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 16)

            ForEach(DepartureTime.allCases, id: \.self) { time in
                FilterCheckRow(
                    title: time.rawValue,
                    isSelected: selectedTimes.contains(time),
                    onToggle: {
                        if selectedTimes.contains(time) {
                            selectedTimes.remove(time)
                        } else {
                            selectedTimes.insert(time)
                        }
                    }
                )
            }

            Text("Показывать варианты с пересадками")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 24)
                .padding(.bottom, 16)

            FilterRadioRow(
                title: "Да",
                isOn: showTransfers == true,
                onSelect: { showTransfers = true }
            )

            FilterRadioRow(
                title: "Нет",
                isOn: showTransfers == false,
                onSelect: { showTransfers = false }
            )

            Spacer()

            if isAnyFilterSelected {
                Button(action: {
                    onApply?(selectedTimes, showTransfers)
                    dismiss()
                }) {
                    Text("Применить")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.trainsBlue)
                        .cornerRadius(16)
                }
                .padding(.bottom, 16)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Components
private struct FilterCheckRow: View {
    let title: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.trainsBlack, lineWidth: 2)
                    .frame(width: 18, height: 18)

                if isSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.trainsBlack)
                        .frame(width: 18, height: 18)

                    Image(systemName: "checkmark")
                        .foregroundColor(.trainsWhite)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .padding(.bottom, 10)
    }
}

private struct FilterRadioRow: View {
    let title: String
    let isOn: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.trainsBlack, lineWidth: 2)
                    .frame(width: 18, height: 18)

                if isOn {
                    Circle()
                        .fill(Color.trainsBlack)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .padding(.bottom, 10)
    }
}

// MARK: - Models
enum DepartureTime: String, CaseIterable {
    case morning = "Утро 06:00 - 12:00"
    case day = "День 12:00 - 18:00"
    case evening = "Вечер 18:00 - 00:00"
    case night = "Ночь 00:00 - 06:00"
}

// MARK: - Preview
#Preview {
    FiltersView()
}
