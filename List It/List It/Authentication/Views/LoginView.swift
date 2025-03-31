//
//  LoginView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var db: Supabase
    var body: some View {
        VStack() {
            Text("Welcome\nBack")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .font(.system(size: 32, weight: .bold, design: .default))

            CustomTextField(icon: "envelope", placeholder: "email", key: $db.email, isPassword: false)
            CustomTextField(icon: "lock", placeholder: "password", key: $db.password, isPassword: true)
            
            Button {
                print("Sign in")
            } label: {
                Text("Sign in")
                    .textCase(.uppercase)
                    .bold()
            }
            .frame(width: 300, height: 50)
            .background(Color.orange)
            .foregroundStyle(.white)
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
