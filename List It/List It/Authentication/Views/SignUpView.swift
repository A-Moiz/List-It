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
        NavigationStack {
            VStack {
                Text("Create\nAccount")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .font(.system(size: 32, weight: .bold, design: .default))
                
                CustomTextField(icon: "person", placeholder: "name", key: $db.name, isPassword: false)
                CustomTextField(icon: "envelope", placeholder: "email", key: $db.email, isPassword: false)
                CustomTextField(icon: "lock", placeholder: "password", key: $db.password, isPassword: true)
                CustomTextField(icon: "lock", placeholder: "confirm password", key: $db.confirmPassword, isPassword: true)
                
                Button {
                    print("Sign up")
                } label: {
                    Text("Sign up")
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
                    Text("Already have an account?")
                    NavigationLink(destination: LoginView(db: db)) {
                        Text("Sign in")
                            .foregroundStyle(Color(hex: "4B0082"))
                            .textCase(.uppercase)
                            .bold()
                    }
                }
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: WelcomeView(db: db)) {
                        Image("left")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView(db: Supabase())
}
