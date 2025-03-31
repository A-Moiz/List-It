//
//  WelcomeView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase
    var body: some View {
        NavigationStack {
            VStack {
                Image("app-icon")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                    .shadow(color: .black, radius: 10, x: 0, y: 5)
                
                Text("Plan,\nPrioritise,\nProduce")
                    .font(.largeTitle)
                    .padding()
                    .bold()
                
                NavigationLink(destination: SignUpView(db: db)) {
                    Text("Get Started")
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    WelcomeView(db: Supabase())
}
