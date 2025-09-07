//
//  SettingsView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Views
struct SettingsView: View {
    var body: some View {
        Image(systemName: "gearshape")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }
}

#Preview {
    SettingsView()
}
