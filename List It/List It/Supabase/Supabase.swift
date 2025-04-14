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
    @Published var lists = [
        List(id: UUID().uuidString, listName: "Today", bgColorHex: "#FF9500", dateCreated: Date(), isDefault: true, collections: []),
        List(id: UUID().uuidString, listName: "Completed", bgColorHex: "#34C759", dateCreated: Date(), isDefault: true, collections: []),
        List(id: UUID().uuidString, listName: "Not Completed", bgColorHex: "#FF3B30", dateCreated: Date(), isDefault: true, collections: [])
    ]
    
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
    
    func moveToCompletedList(task: Task, fromCollection: Collection) {
        guard let currentListIndex = lists.firstIndex(where: { $0.collections.contains(where: { $0.id == fromCollection.id }) }) else {
            return
        }
        
        if let collectionIndex = lists[currentListIndex].collections.firstIndex(where: { $0.id == fromCollection.id }),
           let taskIndex = lists[currentListIndex].collections[collectionIndex].tasks.firstIndex(where: { $0.id == task.id }) {
            lists[currentListIndex].collections[collectionIndex].tasks.remove(at: taskIndex)
        }
        
        guard let completedListIndex = lists.firstIndex(where: { $0.listName == "Completed" }) else { return }

        if let completedCollectionIndex = lists[completedListIndex].collections.firstIndex(where: { $0.collectionName == fromCollection.collectionName }) {
            lists[completedListIndex].collections[completedCollectionIndex].tasks.append(task)
        } else {
            let newCollection = Collection(
                id: UUID().uuidString,
                collectionName: fromCollection.collectionName,
                bgColorHex: fromCollection.bgColorHex,
                dateCreated: Date(),
                tasks: [task],
                notes: []
            )
            lists[completedListIndex].collections.append(newCollection)
        }
    }
}
