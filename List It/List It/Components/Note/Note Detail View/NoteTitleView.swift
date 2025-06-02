//
//  NoteTitleView.swift
//  List It
//
//  Created by Abdul Moiz on 01/06/2025.
//

import SwiftUI

struct NoteTitleView: View {
    // MARK: - Properties
    @Binding var editedTitle: String
    @Binding var selectedColorHex: String
    @Binding var animateContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 2)
            
            TextField("Enter title...", text: $editedTitle)
                .font(.title3.bold())
                .foregroundStyle(Color.primary)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: selectedColorHex).opacity(0.5), lineWidth: 1.5)
                )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}
