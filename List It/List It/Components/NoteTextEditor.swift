//
//  NoteTextEditor.swift
//  List It
//
//  Created by Abdul Moiz on 02/06/2025.
//

import SwiftUI

struct NoteTextEditor: View {
    // MARK: - Properties
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: - Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.orange : Color.clear, lineWidth: 2)
                )
            
            // MARK: - Text Editor
            TextEditor(text: $text)
                .font(.body)
                .padding(12)
                .background(Color.clear)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
            
            // MARK: - Placeholder
            if text.isEmpty {
                Text("Start writing your note here...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

//#Preview {
//    NoteTextEditor()
//}
