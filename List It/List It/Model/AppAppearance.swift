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
    case midnight
    case midnightvelvet
    case navy
    case cream
    case warmpaper
    case iceblue
    
    var title: String {
        switch self {
        case .device: return "Device Theme"
        case .midnight: return "Midnight"
        case .midnightvelvet: return "Midnight Velvet"
        case .navy: return "Navy"
        case .cream: return "Cream"
        case .warmpaper: return "Warm Paper"
        case .iceblue: return "Ice Blue"
        }
    }
    
    var subtitle: String {
        switch self {
        case .device: return "Match your device theme"
        case .midnight: return "#202024"
        case .midnightvelvet: return "#240b36"
        case .navy: return "#0b1222"
        case .cream: return "#FDFBD4"
        case .warmpaper: return "#e9e7e1"
        case .iceblue: return "#EDF4FF"
        }
    }
    
    var backgroundColor: Color? {
        switch self {
        case .device: return nil
        case .midnight: return Color(hex: "202024")
        case .midnightvelvet: return Color(hex: "#240b36")
        case .navy: return Color(hex: "#0b1222")
        case .cream: return Color(hex: "#FDFBD4")
        case .warmpaper: return Color(hex: "#e9e7e1")
        case .iceblue: return Color(hex: "#EDF4FF")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .device: return nil
        case .midnight, .midnightvelvet, .navy: return .dark
        case .cream, .warmpaper, .iceblue: return .light
        }
    }
}
