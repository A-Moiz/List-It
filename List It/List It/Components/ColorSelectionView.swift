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

//#Preview {
//    @Previewable @State var selectedColor: String = ""
//    @Previewable @State var listColorHexes: [String] = [
//        "#FF3B30", // red
//        "#007AFF", // blue
//        "#34C759", // green
//        "#FFD60A", // yellow
//        "#AF52DE", // purple
//        "#FF2D55", // pink
//        "#5856D6", // indigo
//        "#00C7BE", // mint
//        "#FF9500"  // orange
//    ]
//    ColorSelectionView(colorHexes: listColorHexes, selectedHex: $selectedColor)
//}
