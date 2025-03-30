//
//  LoginView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            Text("Welcome\nBack")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .font(.system(size: 40, weight: .bold, design: .default))
            
            VStack(spacing: 16) {
                CustomTextField(icon: "envelope.fill", placeholder: "Email", key: $db.email, isPassword: false)
                CustomTextField(icon: "lock.fill", placeholder: "Password", key: $db.password, isPassword: true)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button {
                print("Sign in")
            } label: {
                Text("Sign in")
                    .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                    .textCase(.uppercase)
                    .bold()
            }
            .frame(width: 300, height: 50)
            .background(db.email.isEmpty || db.password.isEmpty ? Color.orange.opacity(0.2) : Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                Button {
                    print("Going to sign up page...")
                } label: {
                    Text("Sign up")
                        .textCase(.uppercase)
                        .bold()
                }
            }
            .padding(.top, 30)
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LoginView(db: Supabase())
}
