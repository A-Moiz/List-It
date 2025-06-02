//
//  ColorSelectionButton.swift
//  List It
//
//  Created by Abdul Moiz on 02/06/2025.
//

import SwiftUI

struct ColorSelectionButton: View {
    // MARK: - Properties
    let hex: String
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // MARK: - Main color circle
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: isSelected ? 44 : 40, height: isSelected ? 44 : 40)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    )
                
                // MARK: - Selection indicator
                if isSelected {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: .blue.opacity(0.3), radius: 4)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(.blue)
                                .frame(width: 24, height: 24)
                        )
                        .offset(x: 18, y: -18)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}
