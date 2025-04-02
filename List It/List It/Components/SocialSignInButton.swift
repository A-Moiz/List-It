//
//  SocialSignInButton.swift
//  List It
//
//  Created by Abdul Moiz on 02/04/2025.
//

import SwiftUI

struct SocialSignInButton: View {
    var action: () -> Void
    var icon: String
    var isSystemIcon: Bool = false
    var backgroundColor: Color
    @Environment(\.colorScheme) var colorScheme
    private var buttonBackground: Color {
        if backgroundColor == .black {
            return colorScheme == .dark ? Color(hex: "2A2A2A") : .black
        } else {
            return colorScheme == .dark ? Color(hex: "2A2A2A") : .white
        }
    }
    private var iconColor: Color {
        if backgroundColor == .black {
            return .white
        } else {
            return colorScheme == .dark ? .white : .black
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSystemIcon {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(iconColor)
                } else {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(iconColor)
                }
            }
            .frame(width: 50, height: 50)
            .background(buttonBackground)
            .clipShape(Circle())
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    SocialSignInButton(action: { print("Button tapped") }, icon: "applelogo", backgroundColor: .black)
}
