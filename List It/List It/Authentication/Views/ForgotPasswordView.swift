//
//  ForgotPasswordView.swift
//  List It
//
//  Created by Abdul Moiz on 01/05/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    // MARK: - Properties
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
                    // MARK: - Custom title
                    PageTitle(textOne: "Reset", textTwo: "Password")
                    
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // MARK: - Email text field
                    VStack(spacing: 20) {
                        CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $db.resetEmail, isPassword: false, showPassword: false)
                            .padding(.horizontal)
                    }
                    
                    Button {
                        db.sendResetEmail(email: db.resetEmail) { success, error in
                            if success {
                                helper.showAlertWithMessage("If there is an account associated with \(db.resetEmail), a reset link will be sent to your email.")
                            } else {
                                helper.showAlertWithMessage("Error resetting password: \(error ?? "Unknown error")")
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

//#Preview {
//    ForgotPasswordView(db: Supabase(), helper: Helper())
//}
