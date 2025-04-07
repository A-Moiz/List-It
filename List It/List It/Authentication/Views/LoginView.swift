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
                        print("Forgot Password Tapped")
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(AppConstants.secondaryColor(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    
                    Button {
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
        }
    }
    
    func resetFields() {
        db.email = ""
        db.password = ""
    }
}

#Preview {
    LoginView(db: Supabase(), helper: Helper())
}
