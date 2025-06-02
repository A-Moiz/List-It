//
//  ModernTextField.swift
//  List It
//
//  Created by Abdul Moiz on 02/06/2025.
//

import SwiftUI

struct ModernTextField: View {
    // MARK: - Properties
    let icon: String
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isFocused ? .blue : .secondary)
                .frame(width: 20)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .fontWeight(.medium)
                .focused($isFocused)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
