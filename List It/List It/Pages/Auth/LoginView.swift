//
//  LoginView.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var goToSignup: Bool = false
    @State private var showForgotPasswordView: Bool = false
    @Environment(Supabase.self) var db
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        @Bindable var db = db
        
        NavigationStack {
            VStack {
                PageTitle(textOne: "Welcome", textTwo: "Back")
                
                VStack {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $db.email, isPassword: false, showPassword: false)
                        .keyboardType(.emailAddress)
                    
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $db.password, isPassword: true, showPassword: false)
                    
                    HStack {
                        Spacer()
                        Button {
                            showForgotPasswordView = true
                        } label: {
                            Text("Forgot Password?")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
                
                Button {
                    signUserIn()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding()
                    } else {
                        ButtonView(buttonTxt: "Sign in", showArrow: false)
                            .padding()
                    }
                }
                .disabled(isLoading)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    Button {
                        goToSignup = true
                    } label: {
                        Text("Sign Up")
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)
                            .underline()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $goToSignup) {
                SignUpView()
            }
            .onAppear {
                db.resetFields()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showForgotPasswordView) {
                ForgotPasswordView()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    // MARK: - Sign in
    func signUserIn() {
        Task {
            isLoading = true
            let success = await db.signIn(email: db.email.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), password: db.password)
            
            await MainActor.run {
                isLoading = false
                if success {
                    isSignedIn = true
                } else {
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(Supabase())
}
