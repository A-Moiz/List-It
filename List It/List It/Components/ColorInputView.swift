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
            Text("Color")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ColorSelectionView(
                colorHexes: db.listColorHexes,
                selectedHex: $selectedColorHex
            )
            
            if !selectedColorHex.isEmpty {
                Text(selectedColorHex.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
        }
    }
}

// MARK: - Color grid
struct ColorSelectionView: View {
    let colorHexes: [String]
    @Binding var selectedHex: String
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(colorHexes, id: \.self) { hex in
                ColorSelectionButton(
                    hex: hex,
                    isSelected: selectedHex == hex
                ) {
                    selectedHex = hex
                }
            }
        }
    }
}

// MARK: - Color swatch
struct ColorSelectionButton: View {
    let hex: String
    let isSelected: Bool
    let action: () -> Void
    
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(hex: hex))
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.orange, lineWidth: isSelected ? 2.5 : 0)
                )
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    @Previewable @State var text: String = ""
    ColorInputView(selectedColorHex: $text)
}
