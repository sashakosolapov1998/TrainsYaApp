//
//  TrainsYaApp.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 21/8/25.
//

import SwiftUI

@main
struct TrainsYaApp: App {
    @StateObject private var errorManager = ErrorManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(errorManager)
                .fullScreenCover(item: $errorManager.presentedError,
                                 onDismiss: { errorManager.dismiss() }) { err in
                    ErrorScreen(type: err.type)
                }
        }
    }
}
