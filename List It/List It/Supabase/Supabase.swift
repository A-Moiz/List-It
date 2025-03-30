//
//  Supabase.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import Foundation
import Supabase

class Supabase: ObservableObject {
    static let shared = Supabase()
    private let supabaseClient: SupabaseClient
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    init() {
        supabaseClient = SupabaseClient(supabaseURL: URL(string: Config.SUPABASE_URL)!, supabaseKey: Config.SUPABASE_KEY)
    }
    
    func signUp() {
        print("Name: \(name)")
        print("Email: \(email)")
        print("Password: \(password)")
        print("Passwords match: \(password == confirmPassword)")
    }
}
