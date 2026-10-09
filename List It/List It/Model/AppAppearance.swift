//
//  AppAppearance.swift
//  List It
//
//  Created by Abdul Moiz on 09/10/2026.
//

import Foundation
import  SwiftUI

enum AppAppearance: String, CaseIterable {
    case device
    case graphite
    case midnight
    case midnightvelvet
    
    var title: String {
        switch self {
        case .device: return "Device Theme"
        case .graphite: return "Graphite"
        case .midnight: return "Midnight"
        case .midnightvelvet: return "Midnight Velvet"
        }
    }
    
    var subtitle: String {
        switch self {
        case .device: return "Match your iPhone's light or dark setting"
        case .graphite: return "#36373F"
        case .midnight: return "#202024"
        case .midnightvelvet: return "#240b36"
        }
    }
    
    var backgroundColor: Color? {
        switch self {
        case .device: return nil
        case .graphite: return Color(hex: "36373F")
        case .midnight: return Color(hex: "202024")
        case .midnightvelvet: return Color(hex: "#240b36")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .device: return nil
        case .graphite, .midnight, .midnightvelvet: return .dark
        }
    }
}
