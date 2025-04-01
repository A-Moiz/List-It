//
//  CustomSearchBar.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String
    var prompt: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(prompt, text: $text)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.none)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var text: String = ""
    var prompt: String = "Search Collection..."
    CustomSearchBar(text: $text, prompt: prompt)
}
