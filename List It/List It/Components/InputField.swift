//
//  InputField.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import SwiftUI

struct InputField: View {
    @State var icon: String
    @Binding var text: String
    @State var placeholder: String
    @State var isMultiline: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
            
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.body)
            } else {
                TextField(placeholder, text: $text)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    @Previewable @State var text: String = ""
    InputField(icon: "", text: $text, placeholder: "")
}
