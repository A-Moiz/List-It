//
//  LoginView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct LoginView: View {
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
                    PageTitle(textOne: "Welcome", textTwo: "Back")
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $db.email, isPassword: false, showPassword: false)
                        CustomTextField(icon: "lock.fill", placeholder: "Password", text: $db.password, isPassword: true, showPassword: false)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        showForgotPasswordView = true
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(AppConstants.secondaryColor(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    
                    Button {
                        db.loginUser { success, message in
                            if success {
                                isSignedIn = true
                                print("Signed in")
                            } else if let message = message {
                                helper.showAlertWithMessage(message)
                            }
                        }
                    } label: {
                        ButtonView(text: "SIGN IN", icon: "arrow.right")
                    }
                    .padding(.horizontal)
                    
                    CustomDivider(text: "OR")
                    
                    HStack(spacing: 20) {
                        SocialSignInButton(action: { print("Google sign in") }, icon: "google-icon", backgroundColor: .white)
                        
                        SocialSignInButton(action: { print("Apple sign in") }, icon: "applelogo", isSystemIcon: true, backgroundColor: .black)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        resetFields()
                        isNavigating = true
                    } label: {
                        NavigationBackButton()
                    }
                }
            }
            .background(
                NavigationLink(destination: WelcomeView(db: db, helper: helper), isActive: $isNavigating) {
                    EmptyView()
                }
                .hidden()
            )
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showForgotPasswordView) {
                ForgotPasswordView(db: db, helper: helper)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    func resetFields() {
        db.email = ""
        db.password = ""
    }
    
    func checkFields() {
        if !db.isValidEmail() {
            helper.showAlertWithMessage("")
        }
    }
}

#Preview {
    LoginView(db: Supabase(), helper: Helper())
}
