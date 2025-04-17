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
        List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#FF9500", dateCreated: Date(), type: .regular, collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "checkmark.circle.fill", listName: "Completed", isDefault: true, bgColorHex: "#34C759", dateCreated: Date(), type: .completed([]), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "x.circle.fill", listName: "Not Completed", isDefault: true, bgColorHex: "#FF3B30", dateCreated: Date(), type: .notCompleted([]), collections: [], isPinned: false)
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
    
    func moveToCompletedList(task: Task, fromList: List) {
        // 1. Find the index of the source list
        guard let fromListIndex = lists.firstIndex(where: { $0.id == fromList.id }) else {
            return
        }

        // 2. Remove the task from the source list
        if let taskIndex = lists[fromListIndex].tasks?.firstIndex(where: { $0.id == task.id }) {
            lists[fromListIndex].tasks?.remove(at: taskIndex)
        }

        // 3. Find the 'Completed' list
        guard let completedListIndex = lists.firstIndex(where: { $0.listName == "Completed" }) else {
            return
        }

        // 4. Append task to completed list with updated properties
        var completedTask = task
        completedTask.isCompleted = true
        completedTask.dateCompleted = Date()

        if lists[completedListIndex].tasks != nil {
            lists[completedListIndex].tasks?.append(completedTask)
        } else {
            lists[completedListIndex].tasks = [completedTask]
        }
    }
}
