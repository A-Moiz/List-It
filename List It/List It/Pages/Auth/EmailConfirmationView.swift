//
//  EmailConfirmationView.swift
//  List It
//
//  Created by Abdul Moiz on 03/01/2026.
//

import SwiftUI
import Lottie
internal import PostgREST

struct EmailConfirmationView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    @State private var isCheckingVerification = false
    @State private var resendCooldown: Int = 0
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if db.verificationStatus == .verified {
                        SuccessView()
                    } else {
                        PendingVerificationView(userID: db.userID, name: db.name, email: db.email, password: db.password, isCheckingVerification: $isCheckingVerification, resendCooldown: resendCooldown)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        deleteUser()
                    }
                }
            }
        }
        .task {
            isCheckingVerification = true
            await db.verificationCheck(userID: db.userID, name: db.name, email: db.email, password: db.password)
            isCheckingVerification = false
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: db.verificationStatus) { _, newStatus in
            if newStatus == .verified {
                redirectUser()
            }
        }
    }
    
    // MARK: - Delete user on cancel
    func deleteUser() {
        Task {
            guard !db.userID.isEmpty else {
                db.alertTitle = "Error"
                db.alertMessage = "User ID is empty"
                showAlert = true
                return
            }
            
            if await !db.deleteAccountById(userID: db.userID) {
                showAlert = true
            } else {
                dismiss()
            }
        }
    }
    
    // MARK: - Redirect user
    func redirectUser() {
        Task {
            isCheckingVerification = false
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await db.signIn(email: db.email, password: db.password)
            await MainActor.run {
                isSignedIn = true
            }
        }
    }
}

// MARK: - Success view
struct SuccessView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80, weight: .medium))
                .foregroundStyle(Color.green)
            VStack(spacing: 16) {
                Text("Email Verified!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("🎉 Congratulations! Your email has been successfully verified. We're setting up your account...")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Pending view
struct PendingVerificationView: View {
    @State var userID: String
    @State var name: String
    @State var email: String
    @State var password: String
    @Binding var isCheckingVerification: Bool
    @State var resendCooldown: Int
    @Environment(Supabase.self) var db
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.blue.opacity(0.05))
                    .frame(height: 240)
                
                GeometryReader { geometry in
                    if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json") {
                        LottieView {
                            await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                        }
                        .playing(loopMode: .loop)
                        .frame(width: geometry.size.width, height: 240)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.blue)
                                .symbolEffect(.bounce, options: .repeat(.continuous))
                            
                            Text("📧")
                                .font(.system(size: 40))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 240)
            }
            
            VStack(spacing: 12) {
                Text("Check Your Email")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("We've sent a verification link to")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(email)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.blue)
            }
            
            Text("How to verify: Check your inbox, tap the link, return here, and tap the button below.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Button {
                    Task {
                        isCheckingVerification = true
                        await db.verificationCheck(userID: userID, name: name, email: email, password: password)
                        isCheckingVerification = false
                    }
                } label: {
                    HStack(spacing: 12) {
                        if isCheckingVerification {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                        }
                        Text(isCheckingVerification ? "Checking..." : "I've verified my email")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue))
                }
                .disabled(isCheckingVerification)
                .opacity(isCheckingVerification ? 0.7 : 1.0)
            }
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    EmailConfirmationView()
        .environment(Supabase())
}
