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
        if !detailsFilled() {
            print("All fields must be filled in")
            return
        }
        
        if !isValidName() {
            print("Invalid Name")
            return
        }
        
        if !isValidEmail() {
            print("Invalid Email")
            return
        }
        
        if !isValidPassword() {
            print("Password must be at least 6 characters long")
            return
        }
        
        if !passwordsMatch() {
            print("Passwords do not match")
            return
        }
        
        print("Account created successfully!")
    }
    
    func detailsFilled() -> Bool {
        return !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    func isValidName() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameRegex = "^[a-zA-Z]+(?: [a-zA-Z]+)*$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: trimmedName)
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isValidPassword() -> Bool {
        return password.count >= 6
    }
    
    func passwordsMatch() -> Bool {
        return password == confirmPassword
    }
}
