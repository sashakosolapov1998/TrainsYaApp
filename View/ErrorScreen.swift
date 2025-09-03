//
//  ErrorScreen.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI

// MARK: - Models
enum AppErrorType: Equatable {
    case noInternet
    case serverError
}

// MARK: - Views
struct ErrorScreen: View {
    let type: AppErrorType

    var body: some View {
        VStack {
            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .clipShape(RoundedRectangle(cornerRadius: 40))

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 12)

            Spacer()
        }
        .padding()
    }

    private var imageName: String {
        switch type {
        case .noInternet: return "No internet"
        case .serverError: return "server error"
        }
    }

    private var title: String {
        switch type {
        case .noInternet: return "Нет интернета"
        case .serverError: return "Ошибка сервера"
        }
    }
}


// MARK: - Preview
#Preview {
    ErrorScreen(type: .serverError)
}
