//
//  CardBackground.swift
//  List It
//
//  Created by Abdul Moiz on 29/05/2025.
//

import SwiftUI

struct CardBackground: View {
    // MARK: - Properties
    @Binding var list: List
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.8 : 0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [
                        list.bgColor.opacity(0.3),
                        list.bgColor.opacity(0.1),
                        Color.clear
                    ], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(LinearGradient(colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.3 : 0.5),
                        list.bgColor.opacity(0.4),
                        Color.clear
                    ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: list.bgColor.opacity(colorScheme == .dark ? 0.2 : 0.15), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 15, x: 0, y: 6)
            .frame(width: 140, height: 180)
    }
}

//#Preview {
//    CardBackground()
//}
