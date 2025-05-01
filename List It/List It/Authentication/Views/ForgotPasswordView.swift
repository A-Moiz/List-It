//
//  ForgotPasswordView.swift
//  List It
//
//  Created by Abdul Moiz on 01/05/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    PageTitle(textOne: "Reset", textTwo: "Password")
                    
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $db.resetEmail,
                            isPassword: false,
                            showPassword: false
                        )
                    }
                    .padding(.horizontal)
                    
                    Button {
                        db.sendResetEmail { success, message in
                            if success, let message = message {
                                helper.showAlertWithMessage(message)
                            } else if let message = message {
                                helper.showAlertWithMessage(message)
                            }
                        }
                    } label: {
                        ButtonView(text: "SEND RESET LINK", icon: "arrow.clockwise")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    ForgotPasswordView(db: Supabase(), helper: Helper())
}
