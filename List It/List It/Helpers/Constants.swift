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
    
    static func background(for colorScheme: ColorScheme) -> LinearGradient {
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
    
    static let listColorHexes: [String] = [
        "#FF3B30", // red
        "#007AFF", // blue
        "#34C759", // green
        "#FFD60A", // yellow
        "#AF52DE", // purple
        "#FF2D55", // pink
        "#5856D6", // indigo
        "#00C7BE", // mint
        "#FF9500"  // orange
    ]
}
