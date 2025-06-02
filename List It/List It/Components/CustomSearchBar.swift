//
//  CustomSearchBar.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct CustomSearchBar: View {
    // MARK: - Properties
    @Binding var searchText: String
    let prompt: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.6) : Color.gray)
                .font(.system(size: 16, weight: .medium))
            
            TextField(prompt, text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? .white : .primary)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.6) : Color.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.8 : 0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
    }
}

//#Preview {
//    @Previewable @State var text: String = ""
//    var prompt: String = "Search Collection..."
//    CustomSearchBar(text: $text, prompt: prompt)
//}
