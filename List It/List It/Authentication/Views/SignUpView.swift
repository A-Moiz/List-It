//
//  SignUpView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI
import AuthenticationServices

//struct SignUpView: View {
//    @ObservedObject var db: Supabase
//    @ObservedObject var helper: Helper
//    @Environment(\.colorScheme) var colorScheme
//    @State private var isNavigating = false
//    @State var showEmailVerificationView: Bool = false
//    
//    // Colors - dynamically change based on color scheme
//    private var accentColor: Color {
//        colorScheme == .dark ? Color.orange.opacity(0.8) : Color.orange
//    }
//    private var secondaryColor: Color {
//        colorScheme == .dark ? Color(hex: "FF8C42").opacity(0.9) : Color(hex: "4B0082")
//    }
//    private var backgroundColor: LinearGradient {
//        colorScheme == .dark ?
//            LinearGradient(
//                gradient: Gradient(colors: [Color(hex: "121212"), Color(hex: "232323")]),
//                startPoint: .top,
//                endPoint: .bottom
//            ) :
//            LinearGradient(
//                gradient: Gradient(colors: [Color.white.opacity(0.9), Color.orange.opacity(0.1)]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Background gradient that changes with color scheme
//                backgroundColor
//                .ignoresSafeArea()
//                
//                VStack(spacing: 25) {
//                    // Header
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Create")
//                            .font(.system(size: 38, weight: .bold, design: .rounded))
//                            .foregroundColor(colorScheme == .dark ? .white : .primary)
//                        Text("Account")
//                            .font(.system(size: 38, weight: .bold, design: .rounded))
//                            .foregroundColor(accentColor)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                    
//                    // Form Fields with subtle animation
//                    VStack(spacing: 16) {
//                        CustomTextField(icon: "person.fill", placeholder: "Name", text: $db.name, isPassword: false, showPassword: false)
//                    }
//                    .padding(.horizontal)
//                    
//                    // Sign up button
//                    Button {
//                        
//                    } label: {
//                        HStack {
//                            Text("SIGN UP")
//                                .fontWeight(.bold)
//                            Image(systemName: "arrow.right")
//                                .font(.system(size: 16, weight: .bold))
//                        }
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(
//                                    colors: colorScheme == .dark ?
//                                        [Color(hex: "FF5F1F").opacity(0.8), Color(hex: "FF8C42").opacity(0.7)] :
//                                        [accentColor, accentColor.opacity(0.8)]
//                                ),
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .foregroundColor(.white)
//                        .cornerRadius(16)
//                        .shadow(
//                            color: colorScheme == .dark ?
//                                Color(hex: "FF5F1F").opacity(0.2) :
//                                accentColor.opacity(0.3),
//                            radius: 10, x: 0, y: 5
//                        )
//                    }
//                    .padding(.horizontal)
//                    
//                    // Divider
//                    HStack {
//                        Rectangle()
//                            .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
//                            .frame(height: 1)
//                        
//                        Text("or")
//                            .font(.footnote)
//                            .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
//                            .padding(.horizontal, 8)
//                        
//                        Rectangle()
//                            .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
//                            .frame(height: 1)
//                    }
//                    .padding(.horizontal)
//                    
//                    // Social sign in buttons
////                    HStack(spacing: 20) {
////                        SocialSignInButton(action: signInWithGoogle, icon: "google-icon", backgroundColor: .white)
////                        
////                        SocialSignInButton(action: signInWithApple, icon: "applelogo", isSystemIcon: true, backgroundColor: .black)
////                    }
//                    
//                    Button {
//                        print("Forgot Password Tapped")
//                    } label: {
//                        Text("Forgot Password?")
//                            .font(.footnote)
//                            .foregroundColor(secondaryColor)
//                    }
//                    
//                    Spacer()
//                    
//                    // Bottom navigation bar
//                    HStack {
//                        Text("Already have an account?")
//                            .foregroundColor(.white)
//                        
//                        NavigationLink(destination: LoginView(db: db, helper: helper)) {
//                            Text("SIGN IN")
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                                .underline()
//                        }
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(
//                        LinearGradient(
//                            gradient: Gradient(
//                                colors: colorScheme == .dark ?
//                                    [Color(hex: "1A1A1A"), Color(hex: "FF5F1F").opacity(0.6)] :
//                                    [accentColor, accentColor.opacity(0.9)]
//                            ),
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
//                    .padding(.horizontal)
//                }
//                .padding(.vertical)
//            }
//            .alert(isPresented: $helper.showAlert) {
//                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
//            }
//            .navigationBarBackButtonHidden()
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button {
//                        db.name = ""
//                        db.email = ""
//                        db.password = ""
//                        db.confirmPassword = ""
//                        isNavigating = true
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(colorScheme == .light ? .black : .white)
//                            .padding(8)
//                            .background(Color.gray.opacity(0.1))
//                            .clipShape(Circle())
//                    }
//                }
//            }
//            .background(
//                NavigationLink(destination: WelcomeView(db: db, helper: helper), isActive: $isNavigating) {
//                    EmptyView()
//                }
//                .hidden()
//            )
//            .sheet(isPresented: $showEmailVerificationView, content: {
//                EmailConfirmationView()
//                    .presentationDetents([.height(350)])
//                    .presentationCornerRadius(25)
//                    .interactiveDismissDisabled()
//            })
//        }
//    }
//}

struct SignUpView: View {
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var isNavigating = false
    @State var showEmailVerificationView: Bool = false
    private var backgroundColor: LinearGradient {
        AppConstants.colorScheme == .dark ?
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "121212"), Color(hex: "232323")]),
                startPoint: .top,
                endPoint: .bottom
            ) :
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.9), Color.orange.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                
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
                        print("Forgot Password Tapped")
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(AppConstants.secondaryColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    
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
                            Text("SIGN IN")
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
                        db.name = ""
                        db.email = ""
                        db.password = ""
                        db.confirmPassword = ""
                        isNavigating = true
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppConstants.colorScheme == .light ? .black : .white)
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
