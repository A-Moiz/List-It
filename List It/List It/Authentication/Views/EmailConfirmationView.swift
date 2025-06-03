//
//  EmailConfirmationView.swift
//  List It
//
//  Created by Abdul Moiz on 02/04/2025.
//

import SwiftUI
import Lottie
import Supabase

struct EmailConfirmationView: View {
    // MARK: - Properties
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @Environment(\.dismiss) var dismiss
    @State private var verificationStatus: VerificationStatus = .pending
    @State private var isCheckingVerification = false
    @State private var showSuccessAnimation = false
    @State private var isLoadingUserData = false
    let email: String
    let name: String
    let userId: String
    let password: String
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        if verificationStatus == .verified {
                            // MARK: - Success View
                            successView
                        } else {
                            // MARK: - Pending Verification View
                            pendingVerificationView
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        guard !userId.isEmpty else {
                            helper.showAlertWithMessage("User ID is empty")
                            return
                        }
                        db.deleteAccountById(userId: userId) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    db.resetFields()
                                    isSignedIn = false
                                    dismiss()
                                } else {
                                    helper.showAlertWithMessage("Cleanup error: \(error ?? "Unknown error")")
                                    db.resetFields()
                                    isSignedIn = false
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // MARK: - Success Animation Container
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80, weight: .medium))
                        .foregroundStyle(Color.green)
                        .scaleEffect(showSuccessAnimation ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showSuccessAnimation)
                }
                
                VStack(spacing: 16) {
                    Text("Email Verified!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("🎉 Congratulations! Your email has been successfully verified. We're setting up your account...")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // MARK: - Loading Indicator
            if isLoadingUserData {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.blue)
                    
                    Text("Loading your data...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            }
            
            Spacer()
        }
    }
    
    // MARK: - Pending Verification View
    private var pendingVerificationView: some View {
        VStack(spacing: 40) {
            // MARK: - Large Animation Container
            VStack(spacing: 24) {
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
                
                // MARK: - Header Text
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            
            // MARK: - Web Verification Notice
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.blue)
                    
                    Text("The verification link will open in Safari and show a success page")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.08))
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
            
            // MARK: - Step Instructions
            VStack(spacing: 16) {
                HStack {
                    Text("How to verify")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    ForEach(Array(zip([1, 2, 3, 4], [
                        "Check your email inbox",
                        "Tap the verification link",
                        "Wait for 'Email Verified!' message in Safari",
                        "Return to this app and tap the button below"
                    ])), id: \.0) { step, instruction in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 28, height: 28)
                                
                                Text("\(step)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            
                            Text(instruction)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            }
            
            // MARK: - Error Message
            if case .error(let errorMessage) = verificationStatus {
                Text(errorMessage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // MARK: - Action Buttons
            VStack(spacing: 16) {
                Button {
                    Task {
                        db.insertUserIntoDatabase(userId: userId, fullName: name, email: email) { success, error in
                            if !success {
                                helper.showAlertWithMessage("Error added to Database: \(error ?? "Unknown error")")
                            } else {
                                Task {
                                    await checkEmailVerification()
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        if isCheckingVerification {
                            ProgressView()
                                .scaleEffect(0.9)
                                .tint(.white)
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
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue)
                    )
                }
                .disabled(isCheckingVerification)
                .opacity(isCheckingVerification ? 0.7 : 1.0)
            }
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Check email verification (Callback Route Compatible)
    func checkEmailVerification() async {
        isCheckingVerification = true
        await checkUserInDatabase()
        isCheckingVerification = false
    }
    
    // MARK: - Check database for user record (Callback Route Compatible)
    func checkUserInDatabase() async {
        do {
            let response = try await db.client.database
                .from("users")
                .select("id, email, full_name")
                .eq("email", value: email)
                .execute()
            
            guard let jsonArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] else {
                verificationStatus = .error("Unable to check verification status.")
                return
            }
            
            if !jsonArray.isEmpty {
                verificationStatus = .verified
                showSuccessAnimation = true
                await loadUserDataAndRedirect()
            } else {
                verificationStatus = .error("Email not yet verified. Please:\n\n1. Check your email inbox\n2. Tap the verification link\n3. Wait for 'Email Verified!' message\n4. Return here and try again")
            }
        } catch {
            verificationStatus = .error("Database check failed. Please try again.")
        }
    }
    
    // MARK: - Load user data and redirect to AllListsView
    func loadUserDataAndRedirect() async {
        isLoadingUserData = true
        let signInSuccess = await withCheckedContinuation { continuation in
            db.signInUser(email: email, password: password) { success, error in
                if !success {
                    helper.showAlertWithMessage("Sign up failed: \(error ?? "Unknown error")")
                }
                continuation.resume(returning: success)
            }
        }
        
        guard signInSuccess else {
            verificationStatus = .error("Failed to sign in. Please try again.")
            isLoadingUserData = false
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    db.fetchUserLists { success, errorMessage in
                        if !success, let error = errorMessage {
                            helper.showAlertWithMessage("Error with sign up process: \(error ?? "Unknown error")")
                        }
                        continuation.resume()
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    db.fetchUserCollections { success, errorMessage in
                        if !success, let error = errorMessage {
                            helper.showAlertWithMessage("Error with sign up process: \(error ?? "Unknown error")")
                        }
                        continuation.resume()
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    db.fetchUserTasks { success, errorMessage in
                        if !success, let error = errorMessage {
                            helper.showAlertWithMessage("Error with sign up process: \(error ?? "Unknown error")")
                        }
                        continuation.resume()
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    db.fetchUserNotes { success, errorMessage in
                        if !success, let error = errorMessage {
                            helper.showAlertWithMessage("Error with sign up process: \(error ?? "Unknown error")")
                        }
                        continuation.resume()
                    }
                }
            }
        }
        
        isLoadingUserData = false
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        await MainActor.run {
            isSignedIn = true
        }
    }
}

//#Preview {
//    EmailConfirmationView(db: Supabase(), helper: Helper(), email: "", name: "", userId: "")
//}
