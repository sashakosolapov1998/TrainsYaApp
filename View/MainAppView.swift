//
//  MainAppView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct MainAppView: View {
    init() {
        Self.setupTabBarAppearance()
    }
    
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("scheduleTab")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            
            SettingsView()
                .tabItem {
                    Image("tabGear")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
        }
        .accentColor(.trainsBlack)
    }
    
    private static func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .trainsWhite)
        appearance.shadowColor = .trainsGray

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().tintColor = UIColor(Color.trainsBlack)
    }
}

#Preview {
    MainAppView()
}
