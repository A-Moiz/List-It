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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            AppConstants.authBG(for: colorScheme)
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
                
                OrDivider()
                
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
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
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
            EmailConfirmationView()
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
        if !db.detailsFilled() {
            helper.showAlertWithMessage("All fields must be filled in")
            return
        }
        
        if !db.isValidName() {
            helper.showAlertWithMessage("Invalid Name")
            return
        }
        
        if !db.isValidEmail() {
            helper.showAlertWithMessage("Invalid Email")
            return
        }
        
        if !db.isValidPassword() {
            helper.showAlertWithMessage("Password must be at least 6 characters long")
            return
        }
        
        if !db.passwordsMatch() {
            helper.showAlertWithMessage("Passwords do not match")
            return
        }
        
        helper.showAlertWithMessage("Account Ready to be made.")
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
