//
//  LoginView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Properties
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @Environment(\.colorScheme) var colorScheme
    @State private var isNavigating = false
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var showForgotPasswordView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // MARK: - Page title component
                    PageTitle(textOne: "Welcome", textTwo: "Back")
                    
                    Spacer()
                    
                    // MARK: - Login fields
                    VStack(spacing: 20) {
                        CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $db.email, isPassword: false, showPassword: false)
                        CustomTextField(icon: "lock.fill", placeholder: "Password", text: $db.password, isPassword: true, showPassword: false)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Forgot Password
                    Button {
                        showForgotPasswordView = true
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(AppConstants.secondaryColor(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    
                    // MARK: - Sign in button
                    Button {
                        db.email = db.email.trimmingCharacters(in: .whitespacesAndNewlines)
                        db.loginUser { success, message in
                            if success {
                                isSignedIn = true
                            } else if let message = message {
                                helper.showAlertWithMessage(message)
                            }
                        }
                    } label: {
                        ButtonView(text: "SIGN IN", icon: "arrow.right")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // MARK: - Link to sign up page
                    HStack {
                        Text("Don't have an account?")
                        NavigationLink(destination: SignUpView(db: db, helper: helper)) {
                            Text("Sign Up")
                                .foregroundStyle(.blue)
                                .fontWeight(.bold)
                                .underline()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical)
            }
            .navigationBarBackButtonHidden()
            // MARK: - Custom back button
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        db.resetFields()
                        isNavigating = true
                    } label: {
                        NavigationBackButton()
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigating) {
                WelcomeView(db: db, helper: helper)
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showForgotPasswordView) {
                ForgotPasswordView(db: db, helper: helper)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                db.resetFields()
            }
        }
    }
}

//#Preview {
//    LoginView(db: Supabase(), helper: Helper())
//}
