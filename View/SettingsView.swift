//
//  SettingsView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var showAgreement = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        Toggle("Тёмная тема", isOn: $isDarkMode)
                            .tint(Color.trainsBlue)
                            .listRowBackground(Color.clear)
                            .padding(.vertical)
                            .listRowSeparator(.hidden)
                    }

                    Section {
                        HStack {
                            Text("Пользовательское соглашение")
                                .foregroundColor(.trainsBlack)
                                .tracking(0.4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.trainsBlack)
                                .font(.system(size: 24, weight: .medium))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { showAgreement = true }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(.clear)

                VStack {
                    Text("Приложение использует API «Яндекс.Расписания»")
                        .font(.system(size: 12))
                        .foregroundColor(.trainsBlack)
                        .multilineTextAlignment(.center)
                        .padding()
                        .tracking(0.4)

                    Text("Версия 1.0 (beta)")
                        .font(.system(size: 12))
                        .foregroundColor(.trainsBlack)
                        .padding(.bottom, 24)
                        .tracking(0.4)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationDestination(isPresented: $showAgreement) {
                UserAgreementView()
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

private struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Оферта на оказание образовательных услуг дополнительного образования Яндекс.Практикум для физических лиц")
                    .font(.system(size: 24, weight: .bold))
                
                Text("""
                    Данный документ является действующим, если расположен по адресу: https://yandex.ru/legal/practicum_offer
                    
                    Российская Федерация, город Москва
                    
                    """)
                    .font(.system(size: 17, weight: .regular))
                
                Text("1. ТЕРМИНЫ")
                    .font(.system(size: 24, weight: .bold))
                
                Text("""
                Понятия, используемые в Оферте, означают следующее:  Авторизованные адреса — адреса электронной почты каждой Стороны. Авторизованным адресом Исполнителя является адрес электронной почты, указанный в разделе 11 Оферты. Авторизованным адресом Студента является адрес электронной почты, указанный Студентом в Личном кабинете.  Вводный курс — начальный Курс обучения по представленным на Сервисе Программам обучения в рамках выбранной Студентом Профессии или Курсу, рассчитанный на определенное количество часов самостоятельного обучения, который предоставляется Студенту единожды при регистрации на Сервисе на безвозмездной основе. В процессе обучения в рамках Вводного курса Студенту предоставляется возможность ознакомления с работой Сервиса и определения возможности Студента продолжить обучение в рамках Полного курса по выбранной Студентом Программе обучения. Точное количество часов обучения в рамках Вводного курса зависит от выбранной Студентом Профессии или Курса и определяется в Программе обучения, размещенной на Сервисе. Максимальный срок освоения Вводного курса составляет 1 (один) год с даты начала обучения.
                """)
                .font(.system(size: 17, weight: .regular))
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Пользовательское соглашение")
        .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

#Preview {
    SettingsView()
}

