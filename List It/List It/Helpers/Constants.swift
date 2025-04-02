//
//  Constants.swift
//  List It
//
//  Created by Abdul Moiz on 02/04/2025.
//

import Foundation
import SwiftUI

enum AppConstants {
    static var accentColor: Color {
        colorScheme == .dark ? Color.orange.opacity(0.8) : Color.orange
    }
    static var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "FF8C42").opacity(0.9) : Color(hex: "4B0082")
    }
    @Environment(\.colorScheme) static var colorScheme
}
