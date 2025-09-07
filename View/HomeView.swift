//
//  HomeView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct HomeView: View {
    @State private var fromText: String = ""
    @State private var toText: String = ""

    @State private var selectedFromCity: String = ""
    @State private var selectedToCity: String = ""

    @State private var isSelectingFrom = false
    @State private var isSelectingTo = false

    @State private var isSelectingFromStation = false
    @State private var isSelectingToStation = false

    @State private var isShowingCarriers = false

    private var canSearch: Bool { !fromText.isEmpty && !toText.isEmpty }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 44) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(1..<6) { _ in
                                    StoryCardView()
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)

                        HStack {
                            VStack(spacing: 0) {
                                Button {
                                    isSelectingFrom = true
                                } label: {
                                    HStack {
                                        Text(fromText.isEmpty ? "Откуда" : fromText)
                                            .foregroundColor(fromText.isEmpty ? .gray : .black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .lineLimit(1)
                                }

                                Button {
                                    isSelectingTo = true
                                } label: {
                                    HStack {
                                        Text(toText.isEmpty ? "Куда" : toText)
                                            .foregroundColor(toText.isEmpty ? .gray : .black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .lineLimit(1)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding()

                            Button {
                                swapEndpoints()
                            } label: {
                                Image("direction")
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding(.trailing, 16)
                        }
                        .background(Color.trainsBlue)
                        .cornerRadius(30)
                        .padding(.horizontal)

                        if canSearch {
                            Button("Найти") {
                                isShowingCarriers = true
                            }
                            .frame(width: 150, height: 60)
                            .foregroundColor(.white)
                            .background(Color.trainsBlue)
                            .cornerRadius(16)
                            .font(.headline)
                            .padding(.top, -32)
                        }
                    }
                    .padding(.bottom, 32)
                }

                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)

            // MARK: - Navigation

            .navigationDestination(isPresented: $isSelectingFrom) {
                CitySelectionView { city in
                    selectedFromCity = city
                    isSelectingFrom = false
                    isSelectingFromStation = true
                }
                .toolbar(.hidden, for: .tabBar)
            }

            .navigationDestination(isPresented: $isSelectingFromStation) {
                StationSelectionView(city: selectedFromCity) { station in
                    fromText = "\(selectedFromCity) (\(station))"
                    isSelectingFromStation = false
                }
                .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(isPresented: $isSelectingTo) {
                CitySelectionView { city in
                    selectedToCity = city
                    isSelectingTo = false
                    isSelectingToStation = true
                }
                .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(isPresented: $isSelectingToStation) {
                StationSelectionView(city: selectedToCity) { station in
                    toText = "\(selectedToCity) (\(station))"
                    isSelectingToStation = false
                }
                .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(isPresented: $isShowingCarriers) {
                CarrierListView(fromText: fromText, toText: toText)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }

    private func swapEndpoints() {
        swap(&fromText, &toText)
    }
}

// MARK: - Components
private struct StoryCardView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("stroriesDefault")
                .resizable()
                .frame(width: 92, height: 140)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.trainsBlue, lineWidth: 4)
                )
            Text("Text Text\nText Text\nText Text")
                .foregroundColor(.white)
                .font(.caption)
                .padding(.leading, 8)
                .padding(.bottom, 12)
        }
        .frame(width: 100, height: 150)
    }
}

#Preview {
    HomeView()
}
