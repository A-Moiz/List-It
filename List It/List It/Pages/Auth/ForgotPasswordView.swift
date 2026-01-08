//
//  ForgotPasswordView.swift
//  List It
//
//  Created by Abdul Moiz on 04/01/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    @State private var showAlert: Bool = false
    
    var body: some View {
        @Bindable var db = db
        
        NavigationStack {
            VStack {
                PageTitle(textOne: "Reset", textTwo: "Password")
                
                Text("Enter your email below to receive a link to reset your password")
                    .font(.system(size: 12, weight: .light))
                    .padding(.top)
                
                CustomTextField(icon: "envelope", placeholder: "Enter email", text: $db.forgotPasswordEmail, isPassword: false, showPassword: false)
                    .padding()
                
                Button {
                    forgotPassword()
                } label: {
                    ButtonView(buttonTxt: "Send Reset Link", showArrow: false)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        db.resetFields()
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Forgot password
    func forgotPassword() {
        Task {
            let success = await db.resetPassword()
            if !success {
                showAlert = true
            } else {
                dismiss()
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environment(Supabase())
}
