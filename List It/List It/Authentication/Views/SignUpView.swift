//
//  SignUpView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack() {
            Text("Create\nAccount")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .font(.system(size: 40, weight: .bold, design: .default))
            
            VStack(spacing: 16) {
                CustomTextField(icon: "person.fill", placeholder: "Full Name", key: $db.name, isPassword: false)
                CustomTextField(icon: "envelope.fill", placeholder: "Email", key: $db.email, isPassword: false)
                CustomTextField(icon: "lock.fill", placeholder: "Password", key: $db.password, isPassword: true)
                CustomTextField(icon: "lock.fill", placeholder: "Confirm Password", key: $db.confirmPassword, isPassword: true)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button {
                print("Sign up")
                db.signUp()
                db.name = ""
                db.email = ""
                db.password = ""
                db.confirmPassword = ""
            } label: {
                Text("Sign up")
                    .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                    .textCase(.uppercase)
                    .bold()
            }
            .frame(width: 300, height: 50)
            .background(db.name.isEmpty || db.email.isEmpty || db.password.isEmpty || db.confirmPassword.isEmpty ? Color.orange.opacity(0.2) : Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
                Button {
                    print("Going to sign in page...")
                } label: {
                    Text("Sign in")
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
    SignUpView(db: Supabase())
}
