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
    @Binding var text: String
    @State var isPassword: Bool
    @State var showPassword: Bool
    @State var isEditing = false
    
    var textfieldBG: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isEditing ? AppConstants.accentColor : (AppConstants.colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)), lineWidth: isEditing ? 2 : 1)
            .background(AppConstants.colorScheme == .dark ? Color(hex: "1E1E1E").cornerRadius(12) : Color.white.opacity(0.8).cornerRadius(12))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEditing || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundStyle(AppConstants.accentColor)
                    .padding(.leading, 30)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(isEditing ? AppConstants.accentColor : Color.gray)
                    .frame(width: 20)
                
                if isPassword && !showPassword {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .foregroundStyle(AppConstants.colorScheme == .dark ? .white : .primary)
                }
                
                if isPassword {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
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
    @Previewable @State var icon: String = "person"
    @Previewable @State var placeholder: String = "Name"
    @Previewable @State var text: String = ""
    @Previewable @State var isPassword: Bool = false
    CustomTextField(icon: icon, placeholder: placeholder, text: $text, isPassword: isPassword, showPassword: false)
}
