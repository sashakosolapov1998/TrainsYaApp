//
//  ErrorScreen.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 3/9/25.
//

import SwiftUI



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
                .accessibilityIdentifier("error_image")

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 12)
                .accessibilityIdentifier("error_title")

            Spacer()
        }
        .padding()
    }

    private var imageName: String {
        switch type {
        case .noInternet: return "noInternet"
        case .serverError: return "serverError"
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
    ErrorScreen(type: AppErrorType.serverError)
}
