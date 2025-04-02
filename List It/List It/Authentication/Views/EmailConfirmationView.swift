//
//  EmailConfirmationView.swift
//  List It
//
//  Created by Abdul Moiz on 02/04/2025.
//

import SwiftUI
import Lottie

struct EmailConfirmationView: View {
    // @Binding var showEmailVerificationView: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                GeometryReader {_ in
                    if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json") {
                        LottieView {
                            await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                        }
                        .playing(loopMode: .loop)
                    }
                }
                
                Text("Verification")
                    .font(.title.bold())
                
                Text("We have sent a verification email to your email address.\nPlease verifiy to continue.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 25)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.blue)
                    }
                }
            }
//            .overlay(alignment: .topTrailing, content: {
//                Button("Cancel") {
//                    showEmailVerificationView = false
//                    isLoading = false
//                    if let user = Auth.auth().currentUser {
//                        user.delete()
//                        let userId = user.uid
//                        Firestore.firestore().collection("users").document(userId).delete()
//                    }
//                }
//                .padding(15)
//            })
            .padding(.bottom, 15)
//            .onReceive(Timer.publish(every: 2, on: .main, in: .default).autoconnect(), perform: { _ in
//                if let user = Auth.auth().currentUser {
//                    user.reload()
//                    if user.isEmailVerified {
//                        showEmailVerificationView = false
//                        emailVerified = true
//                    }
//                }
//            })
        }
    }
}

#Preview {
//    @Previewable @State var showEmailVerificationView: Bool = false
    EmailConfirmationView()
}
