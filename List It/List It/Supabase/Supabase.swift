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
    var client: SupabaseClient {
        return supabaseClient
    }
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var resetEmail: String = ""
    @Published var userLists = [
        List(id: UUID().uuidString, listIcon: "sun.max", listName: "Today", isDefault: true, bgColorHex: "#FF9500", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "sunrise", listName: "Tomorrow", isDefault: true, bgColorHex: "#007AFF", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "checkmark.square.fill", listName: "Completed", isDefault: true, bgColorHex: "#34C759", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "square", listName: "Not Completed", isDefault: true, bgColorHex: "#FF3B30", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "clock.arrow.circlepath", listName: "Overdue", isDefault: true, bgColorHex: "#FF2D55", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "flag.fill", listName: "Priority", isDefault: true, bgColorHex: "#5856D6", dateCreated: Date(), collections: [], isPinned: false)
    ]
    @Published var lists = [
        List(id: UUID().uuidString, listIcon: "sun.max", listName: "Today", isDefault: true, bgColorHex: "#FF9500", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "sunrise", listName: "Tomorrow", isDefault: true, bgColorHex: "#007AFF", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "checkmark.square.fill", listName: "Completed", isDefault: true, bgColorHex: "#34C759", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "square", listName: "Not Completed", isDefault: true, bgColorHex: "#FF3B30", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "clock.arrow.circlepath", listName: "Overdue", isDefault: true, bgColorHex: "#FF2D55", dateCreated: Date(), collections: [], isPinned: false),
        List(id: UUID().uuidString, listIcon: "flag.fill", listName: "Priority", isDefault: true, bgColorHex: "#5856D6", dateCreated: Date(), collections: [], isPinned: false)
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
        
        if !isStrongPassword() {
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
        return trimmedName.count >= 2 && trimmedName.count <= 30 &&
        NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: trimmedName)
    }
    
    //    func isValidName() -> Bool {
    //        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    //        let nameRegex = "^[a-zA-Z]+(?: [a-zA-Z]+)*$"
    //        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: trimmedName)
    //    }
    
    func isValidEmail() -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isStrongPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    //    func isValidPassword() -> Bool {
    //        return password.count >= 6
    //    }
    
    func passwordsMatch() -> Bool {
        return password == confirmPassword
    }
    
    func createUser(completion: @escaping (Bool, String?, String?) -> Void) {
        guard detailsFilled() else {
            completion(false, "All fields must be filled in", nil)
            return
        }
        
        guard isValidName() else {
            completion(false, "Invalid Name", nil)
            return
        }
        
        guard isValidEmail() else {
            completion(false, "Invalid Email", nil)
            return
        }
        
        guard isStrongPassword() else {
            completion(false, "Password must be at least 6 characters long and contain at least 1 letter and 1 number", nil)
            return
        }
        
        guard passwordsMatch() else {
            completion(false, "Passwords do not match", nil)
            return
        }
        
        Task {
            do {
                let userMetadata: [String: AnyJSON] = ["full_name": .string(name)]
                let response = try await client.auth.signUp(
                    email: email,
                    password: password,
                    data: userMetadata
                )
                let userId = response.user.id.uuidString
                
                DispatchQueue.main.async {
                    completion(true, nil, userId)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription, nil)
                }
            }
        }
    }
    
    func loginUser(completion: @escaping (Bool, String?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(false, "Email and password must be filled in")
            return
        }

        guard isValidEmail() else {
            completion(false, "Invalid Email")
            return
        }

        Task {
            do {
                _ = try await client.auth.signIn(email: email, password: password)
//                _ = try await client.auth.signInWithPassword(email: email, password: password)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func sendResetEmail(completion: @escaping (Bool, String?) -> Void) {
        guard isValidEmail() else {
            DispatchQueue.main.async {
                completion(false, "Invalid Email")
            }
            return
        }

        Task {
            do {
                try await client.auth.resetPasswordForEmail(resetEmail)
                DispatchQueue.main.async {
                    completion(true, "Email has been sent to reset your password")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to send reset email: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func moveToCompletedList(task: ToDoTask, fromList: List) {
        // 1. Find the index of the source list
        guard let fromListIndex = lists.firstIndex(where: { $0.id == fromList.id }) else {
            return
        }
        
        // 2. Remove the task from its collection in the source list
        var taskRemovedFromCollection = false
        
        // Loop through each collection in the source list
        for collectionIndex in 0..<(lists[fromListIndex].collections.count) {
            if let taskIndex = lists[fromListIndex].collections[collectionIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                // Remove the task from the collection
                lists[fromListIndex].collections[collectionIndex].tasks.remove(at: taskIndex)
                taskRemovedFromCollection = true
                break
            }
        }
        
        // 3. If task wasn't in a collection, remove it from the list's direct tasks
        if !taskRemovedFromCollection {
            if let taskIndex = lists[fromListIndex].tasks?.firstIndex(where: { $0.id == task.id }) {
                lists[fromListIndex].tasks?.remove(at: taskIndex)
            }
        }
        
        // 4. Find the 'Completed' list
        guard let completedListIndex = lists.firstIndex(where: { $0.listName == "Completed" }) else {
            return
        }
        
        // 5. Append task to completed list with updated properties
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
