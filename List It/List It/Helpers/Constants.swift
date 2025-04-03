//
//  Constants.swift
//  List It
//
//  Created by Abdul Moiz on 02/04/2025.
//

import Foundation
import SwiftUI

enum AppConstants {
    static func accentColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color.orange.opacity(0.8) : Color.orange
    }
    
    static func secondaryColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "FF8C42").opacity(0.9) : Color(hex: "4B0082")
    }
    
    static func authBG(for colorScheme: ColorScheme) -> LinearGradient {
        return colorScheme == .dark ?
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "121212"), Color(hex: "232323")]),
            startPoint: .top,
            endPoint: .bottom
        ) :
        LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.9), Color.orange.opacity(0.1)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
