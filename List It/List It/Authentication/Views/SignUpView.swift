//
//  SignUpView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    // MARK: - Properties
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var isNavigating = false
    @State var showEmailVerificationView: Bool = false
    @State private var userId: String = ""
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    
    var body: some View {
        ZStack {
            AppConstants.background(for: colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // MARK: - Page title
                PageTitle(textOne: "Create", textTwo: "Account")
                
                // MARK: - Sign up text fields
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "person.fill",
                        placeholder: "Name",
                        text: $db.name,
                        isPassword: false,
                        showPassword: false
                    )
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $db.email,
                        isPassword: false,
                        showPassword: false
                    )
                    CustomTextField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $db.password,
                        isPassword: true,
                        showPassword: false
                    )
                    CustomTextField(
                        icon: "lock.fill",
                        placeholder: "Confirm Password",
                        text: $db.confirmPassword,
                        isPassword: true,
                        showPassword: false
                    )
                }
                .padding(.horizontal)
                
                // MARK: - Sign up button
                Button {
                    checkDetails()
                } label: {
                    ButtonView(text: "SIGN UP", icon: "arrow.right")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Link to login page
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
            Alert(
                title: Text(""),
                message: Text(helper.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarBackButtonHidden()
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
        .background(
            NavigationLink(
                destination: WelcomeView(db: db, helper: helper),
                isActive: $isNavigating
            ) {
                EmptyView()
            }
                .hidden()
        )
        .sheet(isPresented: $showEmailVerificationView, content: {
            EmailConfirmationView(
                db: db,
                helper: helper,
                email: db.email,
                name: db.name,
                userId: userId,
                password: db.password
            )
            .presentationDetents([.height(600)])
            .presentationCornerRadius(25)
            .interactiveDismissDisabled()
        })
        .onAppear {
            db.resetFields()
        }
    }
    
    // MARK: - Checking email + create user
    func checkDetails() {
        db.checkEmailExists(email: db.email) { emailExists, errorMessage in
            if let error = errorMessage {
                helper.showAlertWithMessage(error)
                return
            }
            
            if emailExists {
                helper.showAlertWithMessage("This email is already registered. Please use a different email or sign in instead.")
                return
            }
            
            db.createUser { success, message, userId in
                if success, let userId = userId {
                    self.userId = userId
                    showEmailVerificationView = true
                } else if let message = message {
                    helper.showAlertWithMessage(message)
                }
            }
        }
    }
}
//#Preview {
//    SignUpView(db: Supabase(), helper: Helper())
//}
