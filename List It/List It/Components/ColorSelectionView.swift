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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: selectedColor == color ? 30 : 40, height: selectedColor == color ? 30 : 40)
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
    ColorSelectionView(colors: [.blue, .cyan], selectedColor: $selectedColor)
}
