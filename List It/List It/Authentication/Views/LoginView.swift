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
    
    // Colors - dynamically change based on color scheme
    private var accentColor: Color {
        colorScheme == .dark ? Color.orange.opacity(0.8) : Color.orange
    }
    private var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "FF8C42").opacity(0.9) : Color(hex: "4B0082")
    }
    private var backgroundColor: LinearGradient {
        colorScheme == .dark ?
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
                // Background gradient that changes with color scheme
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Welcome")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        Text("Back")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(accentColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Spacer to push content down a bit
                    Spacer().frame(height: 20)
                    
                    // Form Fields with subtle animation
                    VStack(spacing: 20) {
//                        ModernTextField(icon: "envelope.fill", placeholder: "Email", text: $db.email, isPassword: false)
//                        ModernTextField(icon: "lock.fill", placeholder: "Password", text: $db.password, isPassword: true)
                    }
                    .padding(.horizontal)
                    
                    // Forgot Password button
                    Button(action: {
                        print("Forgot Password Tapped")
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(secondaryColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                    
                    // Sign in button
                    Button {
                        print("Sign in")
                    } label: {
                        HStack {
                            Text("SIGN IN")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: colorScheme == .dark ?
                                        [Color(hex: "FF5F1F").opacity(0.8), Color(hex: "FF8C42").opacity(0.7)] :
                                        [accentColor, accentColor.opacity(0.8)]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(
                            color: colorScheme == .dark ?
                                Color(hex: "FF5F1F").opacity(0.2) :
                                accentColor.opacity(0.3),
                            radius: 10, x: 0, y: 5
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("or continue with")
                            .font(.footnote)
                            .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Social sign in buttons
                    HStack(spacing: 20) {
                        SocialSignInButton(action: { print("Google sign in") }, icon: "google-icon", backgroundColor: .white)
                        
                        SocialSignInButton(action: { print("Apple sign in") }, icon: "applelogo", isSystemIcon: true, backgroundColor: .black)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Bottom navigation bar
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                        
                        NavigationLink(destination: SignUpView(db: db, helper: helper)) {
                            Text("SIGN UP")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(
                                colors: colorScheme == .dark ?
                                    [Color(hex: "1A1A1A"), Color(hex: "FF5F1F").opacity(0.6)] :
                                    [accentColor, accentColor.opacity(0.9)]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        db.email = ""
                        db.password = ""
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
        }
    }
}

//struct LoginView: View {
//    @ObservedObject var db: Supabase
//    @ObservedObject var helper: Helper
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text("Welcome\nBack")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .font(.system(size: 32, weight: .bold, design: .default))
//
//                CustomTextField(icon: "envelope", placeholder: "email", key: $db.email, isPassword: false)
//                CustomTextField(icon: "lock", placeholder: "password", key: $db.password, isPassword: true)
//                
//                Button {
//                    print("Sign in")
//                } label: {
//                    Text("Sign in")
//                        .textCase(.uppercase)
//                        .bold()
//                }
//                .frame(width: 300, height: 50)
//                .background(Color.orange)
//                .foregroundStyle(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//                .padding()
//                
//                Spacer()
//                
//                HStack {
//                    Text("Don't have an account?")
//                    NavigationLink(destination: SignUpView(db: db, helper: helper)) {
//                        Text("Sign up")
//                            .foregroundStyle(Color(hex: "4B0082"))
//                            .textCase(.uppercase)
//                            .bold()
//                    }
//                }
//                .padding(.top, 30)
//                .frame(maxWidth: .infinity)
//                .background(Color.orange)
//                .ignoresSafeArea()
//            }
//            .navigationBarBackButtonHidden()
//        }
//    }
//}

#Preview {
    LoginView(db: Supabase(), helper: Helper())
}
