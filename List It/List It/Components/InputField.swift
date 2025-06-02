//
//  InputField.swift
//  List It
//
//  Created by Abdul Moiz on 07/05/2025.
//

import SwiftUI

struct InputField: View {
    // MARK: - Properties
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isMultiline: Bool = false
    
    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
                .padding(.top, isMultiline ? 12 : 0)
            
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}
//#Preview {
//    @Previewable @State var icon: String = "Hello"
//    @Previewable @State var placeholder: String = "Hello"
//    @Previewable @State var text: String = "Hello"
//    InputField(icon: icon, placeholder: placeholder, text: $text)
//}
