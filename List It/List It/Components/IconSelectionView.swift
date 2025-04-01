//
//  IconSelectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct IconSelectionView: View {
    let icons: [String]
    @Binding var selectedIcon: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(selectedIcon == icon ? .blue : .gray)
                        .onTapGesture {
                            selectedIcon = icon
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var selectedIcon: String = "checklist"
    IconSelectionView(icons: ["checklist", "folder", "star", "heart", "person", "bookmark", "pencil", "paintpalette", "camera"], selectedIcon: $selectedIcon)
}
