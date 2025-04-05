//
//  ColorSelectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct ColorSelectionView: View {
    let colorHexes: [String]
    @Binding var selectedHex: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(colorHexes, id: \.self) { hex in
                    let color = Color(hex: hex)
                    
                    Circle()
                        .fill(color)
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? .white : .black, lineWidth: selectedHex == hex ? 4 : 0)
                        )
                        .frame(width: selectedHex == hex ? 30 : 35, height: selectedHex == hex ? 30 : 35)
                        .onTapGesture {
                            selectedHex = hex
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var selectedColor: String = ""
    @Previewable @State var listColorHexes: [String] = [
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
    ColorSelectionView(colorHexes: listColorHexes, selectedHex: $selectedColor)
}
