//
//  ColorInputView.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import SwiftUI

struct ColorInputView: View {
    @Environment(Supabase.self) var db
    @Binding var selectedColorHex: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintpalette")
                    .frame(width: 20)
                Text("Choose a Colour")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            ColorSelectionView(
                colorHexes: db.listColorHexes,
                selectedHex: $selectedColorHex
            )
            
            if !selectedColorHex.isEmpty {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: selectedColorHex))
                        .frame(width: 20, height: 20)
                    Text("Selected: \(selectedColorHex)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Color view
struct ColorSelectionView: View {
    let colorHexes: [String]
    @Binding var selectedHex: String
    @Environment(\.colorScheme) var colorScheme
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(colorHexes, id: \.self) { hex in
                ColorSelectionButton(
                    hex: hex,
                    isSelected: selectedHex == hex,
                    colorScheme: colorScheme
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedHex = hex
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Colors view
struct ColorSelectionButton: View {
    let hex: String
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: isSelected ? 44 : 40, height: isSelected ? 44 : 40)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    )
                
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

#Preview {
    @Previewable @State var text: String = ""
    ColorInputView(selectedColorHex: $text)
}
