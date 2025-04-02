//
//  ButtonView.swift
//  List It
//
//  Created by Abdul Moiz on 03/04/2025.
//

import SwiftUI

struct ButtonView: View {
    @State var text: String
    @State var icon: String
    
    var body: some View {
        HStack {
            Text(text)
                .fontWeight(.bold)
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: AppConstants.colorScheme == .dark ?
                    [Color(hex: "FF5F1F").opacity(0.8), Color(hex: "FF8C42").opacity(0.7)] :
                        [AppConstants.accentColor, AppConstants.accentColor.opacity(0.8)]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(16)
        .shadow(
            color: AppConstants.colorScheme == .dark ?
            Color(hex: "FF5F1F").opacity(0.2) :
                AppConstants.accentColor.opacity(0.3),
            radius: 10, x: 0, y: 5
        )
    }
}

#Preview {
    ButtonView(text: "SIGN UP", icon: "arrow.right")
}
