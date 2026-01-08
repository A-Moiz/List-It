//
//  CustomTextField.swift
//  List It
//
//  Created by Abdul Moiz on 04/01/2026.
//

import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isPassword: Bool
    @State var showPassword: Bool
    @State var isEditing = false
    @Environment(\.colorScheme) var colorScheme
    var textfieldBG: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isEditing ? Color.orange : (colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)), lineWidth: isEditing ? 2 : 1)
            .background(colorScheme == .dark ? Color(hex: "1E1E1E").cornerRadius(12) : Color.white.opacity(0.8).cornerRadius(12))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEditing || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.leading, 30)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isEditing ? .orange : .gray)
                    .frame(width: 20)
                
                if isPassword && !showPassword {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                if isPassword {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(textfieldBG)
            .onTapGesture {
                withAnimation(.spring()) {
                    isEditing = true
                }
            }
            .onSubmit {
                withAnimation(.spring()) {
                    isEditing = false
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    CustomTextField(icon: "person", placeholder: "Enter Name", text: $text, isPassword: false, showPassword: false)
}
