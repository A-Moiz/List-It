//
//  ColorSelectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct ColorSelectionView: View {
    let colors: [Color]
    @Binding var selectedColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? .white : .black, lineWidth: selectedColor == color ? 4 : 0)
                        )
                        .frame(width: selectedColor == color ? 30 : 35, height: selectedColor == color ? 30 : 35)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var selectedColor: Color = .blue
    ColorSelectionView(colors: [.blue, .cyan, .orange, .red, .green], selectedColor: $selectedColor)
}
