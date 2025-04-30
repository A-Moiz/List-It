//
//  EmailConfirmationView.swift
//  List It
//
//  Created by Abdul Moiz on 02/04/2025.
//

import SwiftUI
import Lottie
import Supabase

//struct EmailConfirmationView: View {
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 6) {
//                GeometryReader {_ in
//                    if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json") {
//                        LottieView {
//                            await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
//                        }
//                        .playing(loopMode: .loop)
//                    }
//                }
//
//                Text("Verification")
//                    .font(.title.bold())
//
//                Text("We have sent a verification email to your email address.\nPlease verifiy to continue.")
//                    .multilineTextAlignment(.center)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 25)
//            }
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text("Cancel")
//                            .foregroundStyle(.blue)
//                    }
//                }
//            }
//            .padding(.bottom, 15)
//        }
//    }
//}

//struct EmailConfirmationView: View {
//    @ObservedObject var db: Supabase
//    @ObservedObject var helper: Helper
//    @Environment(\.dismiss) var dismiss
//    @AppStorage("isEmailVerified") var isEmailVerified: Bool = false
//
//    @State private var pollingTask: Task<Void, Never>? = nil
//    @State private var isCancelled = false
//
//    let email: String
//    let name: String
//    let userId: String
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 12) {
//                GeometryReader { _ in
//                    if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json") {
//                        LottieView {
//                            await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
//                        }
//                        .playing(loopMode: .loop)
//                    }
//                }
//
//                Text("Check Your Inbox")
//                    .font(.title.bold())
//
//                Text("We've sent a verification email to **\(email)**.\nPlease check your inbox and confirm your email to continue.")
//                    .multilineTextAlignment(.center)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 25)
//            }
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Cancel") {
//                        isCancelled = true
//                        Task {
//                            await deleteAuthUser()
//                            dismiss()
//                        }
//                    }
//                }
//            }
//            .padding(.bottom, 15)
//            .onAppear {
//                startPolling()
//            }
//            .onDisappear {
//                pollingTask?.cancel()
//            }
//        }
//    }
//
//    //    func startPolling() {
//    //        pollingTask = Task {
//    //            while !Task.isCancelled && !isCancelled {
//    //                do {
//    //                    let session = try await db.client.auth.refreshSession()
//    //                    if session.user.confirmedAt != nil {
//    //                        isEmailVerified = true
//    //                        try await insertIntoUserTable()
//    //                        dismiss()
//    //                        break
//    //                    }
//    //                } catch {
//    //                    helper.showAlertWithMessage("Error checking email confirmation: \(error.localizedDescription)")
//    //                    print("Error checking email confirmation: \(error.localizedDescription)")
//    //                }
//    //
//    //                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
//    //            }
//    //        }
//    //    }
//
//    func startPolling() {
//        pollingTask = Task {
//            while !Task.isCancelled && !isCancelled {
//                do {
//                    // You can use currentSession instead of refreshSession here
//                    guard db.client.auth.session != nil else {
//                        print("No auth session found")
//                        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
//                        continue
//                    }
//
//                    // Just re-check the current user without forcing a refresh
//                    if let user = db.client.auth.currentUser, user.confirmedAt != nil {
//                        print("✅ Email confirmed")
//                        isEmailVerified = true
//                        try await insertIntoUserTable()
//                        dismiss()
//                        break
//                    }
//                } catch {
//                    print("Error checking email confirmation: \(error.localizedDescription)")
//                }
//
//                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
//            }
//        }
//    }
//
//    func insertIntoUserTable() async throws {
//        guard let userUUID = UUID(uuidString: userId) else {
//            throw NSError(domain: "Invalid UUID", code: 1, userInfo: nil)
//        }
//
//        let user = AppUser(id: userUUID, createdAt: Date(), fullName: name, email: email, lists: db.userLists)
//
//        try await db.client.from("users")
//            .upsert(user, onConflict: "id")
//            .execute()
//    }
//
//    func deleteAuthUser() async {
//        do {
//            try await db.client.auth.signOut()
//        } catch {
//            helper.showAlertWithMessage("Error signing out: \(error.localizedDescription)")
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
//}

struct EmailConfirmationView: View {
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @Environment(\.dismiss) var dismiss
    @AppStorage("isEmailVerified") var isEmailVerified: Bool = false
    
    @State private var pollingTask: Task<Void, Never>? = nil
    @State private var isCancelled = false
    
    let email: String
    let name: String
    let userId: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                GeometryReader { _ in
                    if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json") {
                        LottieView {
                            await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                        }
                        .playing(loopMode: .loop)
                    }
                }
                
                Text("Check Your Inbox")
                    .font(.title.bold())
                
                Text("We've sent a verification email to **\(email)**.\nPlease check your inbox and confirm your email to continue.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 25)
                
                Button {
                    Task {
                        try? await insertIntoUserTable()
                    }
                } label: {
                    Text("I've confirmed my email")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                Button {
                    Task {
                        await resendVerificationEmail()
                    }
                } label: {
                    Text("Resend verification email")
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top, 8)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        isCancelled = true
                        Task {
                            await deleteAuthUser()
                            dismiss()
                        }
                    }
                }
            }
            .padding(.bottom, 15)
            .onAppear {
                startPolling()
            }
            .onDisappear {
                pollingTask?.cancel()
            }
        }
    }
    
    func startPolling() {
        pollingTask = Task {
            while !Task.isCancelled && !isCancelled {
                do {
                    // Try to get current session
                    let sessionResponse = try await db.client.auth.session
                    
                    // Check if email is confirmed
                    if sessionResponse != nil && sessionResponse.user.emailConfirmedAt != nil {
                        isEmailVerified = true
                        try await insertIntoUserTable()
                        dismiss()
                        break
                    }
                } catch {
                    print("Error checking session: \(error)")
                }
                
                // Check every 3 seconds
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            }
        }
    }
    
    func resendVerificationEmail() async {
        do {
            try await db.client.auth.resend(
                email: email, type: .signup
            )
            helper.showAlertWithMessage("Verification email resent. Please check your inbox.")
        } catch {
            helper.showAlertWithMessage("Error resending verification email: \(error.localizedDescription)")
        }
    }
    
    func insertIntoUserTable() async throws {
        guard let userUUID = UUID(uuidString: userId) else {
            throw NSError(domain: "Invalid UUID", code: 1, userInfo: nil)
        }
        
        // Try to insert user data
        do {
            try await db.client.database
                .from("users")
                .insert([
                    "id": userId,
                    "full_name": name,
                    "email": email,
                    "lists": nil
                ])
                .execute()
            
            print("User profile created successfully")
            helper.showAlertWithMessage("Account created successfully!")
            dismiss()
        } catch {
            print("Error creating user profile: \(error)")
            helper.showAlertWithMessage("Error creating profile: \(error.localizedDescription)")
        }
    }
    
    func deleteAuthUser() async {
        do {
            try await db.client.auth.signOut()
        } catch {
            helper.showAlertWithMessage("Error signing out: \(error.localizedDescription)")
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    EmailConfirmationView(db: Supabase(), helper: Helper(), email: "", name: "", userId: "")
}
