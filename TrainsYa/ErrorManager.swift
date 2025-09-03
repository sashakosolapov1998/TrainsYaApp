//
//  ErrorManager.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import Foundation

final class ErrorManager: ObservableObject {
    struct PresentedError: Identifiable {
        let id = UUID()
        let type: AppErrorType
    }

    @Published var presentedError: PresentedError?

    func show(_ type: AppErrorType) {
        DispatchQueue.main.async {
            self.presentedError = .init(type: type)
        }
    }

    func dismiss() { presentedError = nil }
}
