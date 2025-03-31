//
//  CustomTextField.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct CustomTextField: View {
    @State var icon: String
    @State var placeholder: String
    @Binding var key: String
    @State var isPassword: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                if !isPassword {
                    TextField(placeholder.capitalized, text: $key)
                } else {
                    SecureField(placeholder.capitalized, text: $key)
                }
            }
            .padding()
            
            Divider()
                .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var icon: String = "person"
    @Previewable @State var placeholder: String = "name"
    @Previewable @State var key: String = ""
    @Previewable @State var isPassword: Bool = false
    CustomTextField(icon: icon, placeholder: placeholder, key: $key, isPassword: isPassword)
}
