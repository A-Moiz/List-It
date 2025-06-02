//
//  NoteDescriptionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/06/2025.
//

import SwiftUI

struct NoteDescriptionView: View {
    // MARK: - Properties
    @Binding var editedDescription: String
    @Binding var selectedColorHex: String
    @Binding var animateContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 2)
            
            TransparentTextEditor(text: $editedDescription)
                .padding(16)
                .frame(minHeight: 200)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: selectedColorHex).opacity(0.5), lineWidth: 1.5)
                )
                .overlay(
                    Group {
                        if editedDescription.isEmpty {
                            Text("Add a description...")
                                .foregroundStyle(Color.secondary.opacity(0.7))
                                .padding(.leading, 24)
                                .padding(.top, 24)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}
