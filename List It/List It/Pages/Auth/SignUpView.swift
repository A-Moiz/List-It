//
//  SignUpView.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI

struct SignUpView: View {
    @Environment(Supabase.self) var db
    @State private var goToLogin: Bool = false
    @State var showEmailVerification: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        @Bindable var db = db
        
        NavigationStack {
            VStack {
                PageTitle(textOne: "Create", textTwo: "Account")
                
                FormView(name: $db.name, email: $db.email, password: $db.password, confirmPassword: $db.confirmPassword, showEmailVerification: $showEmailVerification)
                    .padding()
                
                Button {
                    Task {
                        await signUp()
                    }
                } label: {
                    ButtonView(buttonTxt: "Sign up", showArrow: false)
                        .padding()
                }
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                    Button {
                        goToLogin = true
                    } label: {
                        Text("Sign In")
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)
                            .underline()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $goToLogin) {
                LoginView()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showEmailVerification) {
                EmailConfirmationView()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                db.resetFields()
            }
        }
    }
    
    // MARK: - Sign up user
    func signUp() async {
        if db.name.isEmpty || db.email.isEmpty || db.password.isEmpty || db.confirmPassword.isEmpty {
            db.alertTitle = "Form incomplete"
            db.alertMessage = "All fields must be filled in."
            showAlert = true
            return
        }
        
        guard db.isValidName(), db.isValidEmail(email: db.email), db.isStrongPassword(), db.passwordsMatch() else {
            db.alertTitle = "Invalid input"
            db.alertMessage = "Please ensure your email is valid and password is at least 6 characters with a number."
            showAlert = true
            return
        }
        
        guard await db.isEmailAvailable(email: db.email) else {
            db.alertTitle = "Invalid Email"
            db.alertMessage = "Email is already taken. Please sign up with a different email or sign in."
            showAlert = true
            return
        }
        
        createUser()
    }
    
    // MARK: - Create user
    func createUser() {
        let trimmedName = db.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let trimmedEmail = db.email.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        Task {
            do {
                let (newUserID, success) = try await db.createUser(name: trimmedName, email: trimmedEmail, password: db.password)
                
                await MainActor.run {
                    if success {
                        db.userID = newUserID
                        showEmailVerification = true
                    } else {
                        db.alertTitle = "Error"
                        db.alertMessage = "Account creation failed. Please try again."
                        showAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    db.alertTitle = "System Error"
                    db.alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Form view
struct FormView: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var showEmailVerification: Bool
    
    var body: some View {
        VStack {
            CustomTextField(icon: "person.fill", placeholder: "Name", text: $name, isPassword: false, showPassword: false)
                .disabled(showEmailVerification)
            
            CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email, isPassword: false, showPassword: false)
                .keyboardType(.emailAddress)
                .disabled(showEmailVerification)
            
            CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isPassword: true, showPassword: false)
                .disabled(showEmailVerification)
            
            CustomTextField(icon: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isPassword: true, showPassword: false)
                .disabled(showEmailVerification)
        }
    }
}

#Preview {
    SignUpView()
        .environment(Supabase())
}
