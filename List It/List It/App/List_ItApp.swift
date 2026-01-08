//
//  List_ItApp.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI
import Supabase

@main
struct List_ItApp: App {
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var database = Supabase()
    @State private var isAuthenticating = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticating {
                    ProgressView("Loading...")
                } else if isSignedIn && database.currentUser != nil {
                    AllListsView()
                } else {
                    IntroView()
                }
            }
            .environment(database)
            .task {
                for await (event, session) in database.client.auth.authStateChanges {
                    if event == .initialSession {
                        if let _ = session {
                            let success = await database.initializeSession()
                            
                            await MainActor.run {
                                self.isSignedIn = success
                                self.isAuthenticating = false
                            }
                        } else {
                            await MainActor.run {
                                self.isSignedIn = false
                                self.isAuthenticating = false
                            }
                        }
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
