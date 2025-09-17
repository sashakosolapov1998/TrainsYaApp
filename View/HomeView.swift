//
//  HomeView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var path: [HomeRoute] = []

    private var canSearch: Bool { !vm.fromText.isEmpty && !vm.toText.isEmpty }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ScrollView {
                    VStack(spacing: 44) {
                        StoriesStrip(stories: $vm.stories) { index in
                            vm.tapStory(at: index)
                        }
                        .padding(.top)

                        HStack {
                            VStack(spacing: 0) {
                                Button {
                                    vm.startSelectingFrom()
                                } label: {
                                    HStack {
                                        Text(vm.fromText.isEmpty ? "Откуда" : vm.fromText)
                                            .foregroundColor(vm.fromText.isEmpty ? .gray : .black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .lineLimit(1)
                                }

                                Button {
                                    vm.startSelectingTo()
                                } label: {
                                    HStack {
                                        Text(vm.toText.isEmpty ? "Куда" : vm.toText)
                                            .foregroundColor(vm.toText.isEmpty ? .gray : .black)
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
                                vm.swapDirections()
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
                                vm.searchCarriers()
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
            .task { await vm.loadStories() }

            // MARK: - Navigation

            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .selectFromCity:
                    CitySelectionView { city in
                        print("🟨 [HomeView] open CitySelectionView (FROM), selected city =", city)
                        vm.selectFromCity(city)
                    }
                    .toolbar(.hidden, for: .tabBar)

                case let .selectFromStation(city):
                    StationSelectionView(city: city) { station in
                        print("🟦 [HomeView] open StationSelectionView (FROM), city =", city, "selected station =", station)
                        vm.selectFromStation(station)
                    }
                    .toolbar(.hidden, for: .tabBar)

                case .selectToCity:
                    CitySelectionView { city in
                        print("🟩 [HomeView] open CitySelectionView (TO), selected city =", city)
                        vm.selectToCity(city)
                    }
                    .toolbar(.hidden, for: .tabBar)

                case let .selectToStation(city):
                    StationSelectionView(city: city) { station in
                        print("🟪 [HomeView] open StationSelectionView (TO), city =", city, "selected station =", station)
                        vm.selectToStation(station)
                    }
                    .toolbar(.hidden, for: .tabBar)

                case .carriers:
                    CarrierListView(fromText: vm.fromText, toText: vm.toText)
                        .onAppear { print("🟠 [HomeView] open CarrierListView:", vm.fromText, "→", vm.toText) }
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .onChange(of: vm.route) { route in
                if let route {
                    print("➡️ [HomeView] push route =", route)
                    path.append(route)
                    vm.closeRoute()
                } else {
                    print("ℹ️ [HomeView] route cleared")
                }
        
            }
            .fullScreenCover(isPresented: $vm.showStories) {
                StoriesViewer(stories: $vm.stories, currentIndex: $vm.currentStoryIndex)
                    .ignoresSafeArea()
            }
        }
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
