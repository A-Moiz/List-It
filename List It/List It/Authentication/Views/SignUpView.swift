//
//  SignUpView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var isNavigating = false
    @State var showEmailVerificationView: Bool = false
    @State private var userId: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            AppConstants.background(for: colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                PageTitle(textOne: "Create", textTwo: "Account")
                
                VStack(spacing: 16) {
                    CustomTextField(icon: "person.fill", placeholder: "Name", text: $db.name, isPassword: false, showPassword: false)
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $db.email, isPassword: false, showPassword: false)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $db.password, isPassword: true, showPassword: false)
                    CustomTextField(icon: "lock.fill", placeholder: "Confirm Password", text: $db.confirmPassword, isPassword: true, showPassword: false)
                }
                .padding(.horizontal)
                
                Button {
                    checkDetails()
                } label: {
                    ButtonView(text: "SIGN UP", icon: "arrow.right")
                }
                .padding(.horizontal)
                
                CustomDivider(text: "OR")
                
                HStack(spacing: 20) {
                    SocialSignInButton(action: signInWithGoogle, icon: "google-icon", backgroundColor: .white)
                    
                    SocialSignInButton(action: signInWithApple, icon: "applelogo", isSystemIcon: true, backgroundColor: .black)
                }
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                    NavigationLink(destination: LoginView(db: db, helper: helper)) {
                        Text("Sign In")
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
        .alert(isPresented: $helper.showAlert) {
            Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
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
        .sheet(isPresented: $showEmailVerificationView, content: {
            EmailConfirmationView(db: db, helper: helper, email: db.email, name: db.name, userId: userId)
                .presentationDetents([.height(350)])
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
        })
    }
    
    func resetFields() {
        db.name = ""
        db.email = ""
        db.password = ""
        db.confirmPassword = ""
    }
    
    func checkDetails() {
        db.createUser { success, message, userId in
            if success, let userId = userId {
                self.userId = userId
                showEmailVerificationView = true
            } else if let message = message {
                helper.showAlertWithMessage(message)
            }
        }
    }
    
    func signInWithGoogle() {
        print("Sign in with Google tapped")
    }
    
    func signInWithApple() {
        print("Sign in with Apple tapped")
    }
}

#Preview {
    SignUpView(db: Supabase(), helper: Helper())
}
