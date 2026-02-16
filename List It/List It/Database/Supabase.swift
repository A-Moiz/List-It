//
//  Supabase.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import Foundation
import Observation
import Supabase
import SwiftUI

@Observable
@MainActor
class Supabase {
    static let shared = Supabase()
    let formatter = DateFormatter()
    let decoder = JSONDecoder()
    private let supabaseClient: SupabaseClient
    var client: SupabaseClient {
        return supabaseClient
    }
    var alertTitle: String = ""
    var alertMessage: String = ""
    var verificationStatus: VerificationStatus = .pending
    @ObservationIgnored
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    var userID: String = ""
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var forgotPasswordEmail: String = ""
    var currentUser: AppUser?
    let listColorHexes: [String] = [
        "#FF3B30", // red
        "#007AFF", // blue
        "#34C759", // green
        "#FFD60A", // yellow
        "#AF52DE", // purple
        "#FF2D55", // pink
        "#5856D6", // indigo
        "#00C7BE", // mint
        "#FF9500", // orange
        "#FF69B4"   // pink v2
    ]
    var defaultLists = [
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "sun.max", listName: "Today", isDefault: true, bgColorHex: "#FF9500", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "sunrise", listName: "Tomorrow", isDefault: true, bgColorHex: "#007AFF", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "flag.fill", listName: "Priority", isDefault: true, bgColorHex: "#5856D6", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "checkmark.square.fill", listName: "Completed", isDefault: true, bgColorHex: "#34C759", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "square", listName: "Not Completed", isDefault: true, bgColorHex: "#FF3B30", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "clock.arrow.circlepath", listName: "Overdue", isDefault: true, bgColorHex: "#FF2D55", userId: "", isPinned: false)
    ]
    var lists: [List] = []
    var collections: [Collection] = []
    var tasks: [ToDoTask] = []
    var notes: [Note] = []
    
    init() {
        supabaseClient = SupabaseClient(supabaseURL: URL(string: Config.SUPABASE_URL)!, supabaseKey: Config.SUPABASE_KEY)
    }
    
    // MARK: - Fetch All Lists
    func getFilteredLists(query: String) -> [List] {
        let all = defaultLists + lists
        
        // 1. Sort: Primary by isDefault (true first), Secondary by createdAt
        let sorted = all.sorted {
            if $0.isDefault != $1.isDefault {
                return $0.isDefault && !$1.isDefault // true (default) comes before false
            }
            return $0.createdAt < $1.createdAt // Then oldest to newest
        }
        
        // 2. Filter based on query
        if query.isEmpty {
            return sorted
        } else {
            // Cleaning the query as requested earlier for consistency
            let cleanQuery = query.lowercased().replacingOccurrences(of: " ", with: "")
            return sorted.filter {
                $0.listName.lowercased().replacingOccurrences(of: " ", with: "").contains(cleanQuery)
            }
        }
    }
    
    // MARK: - Fetch pinned lists
    func pinnedLists(query: String) -> [List] {
        let all = defaultLists + lists
        let sorted = all.sorted { $0.createdAt < $1.createdAt }
        if query.isEmpty {
            return sorted.filter { $0.isPinned }
        } else {
            return sorted.filter( {$0.isPinned && $0.listName.localizedCaseInsensitiveContains(query) } )
        }
    }
    
    // MARK: - Setting up alerts
    func setError(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
    }
    
    // MARK: - Date formatter
    func formattedDate(_ date: Date) -> String {
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Check if user email exists in database
    func isEmailAvailable(email: String) async -> Bool {
        do {
            let response = try await client
                .from("users")
                .select("id", head: true, count: .exact)
                .eq("email", value: email)
                .execute()
            
            let count = response.count ?? 0
            return count == 0
            
        } catch {
            await MainActor.run {
                setError(title: "Error checking Email", message: "Unable to verify email availability. Please try again.")
            }
            return false
        }
    }
    
    // MARK: - Create user
    func createUser(name: String, email: String, password: String) async throws -> (String, Bool) {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(name)],
                redirectTo: URL(string: "https://list-it-dom.netlify.app")
            )
            
            let userExists = response.user.identities?.isEmpty ?? true
            if userExists {
                await MainActor.run {
                    setError(title: "Check your email", message: "If this email is new, a confirmation link was sent.")
                }
            }
            
            return (response.user.id.uuidString, true)
            
        } catch {
            await MainActor.run {
                setError(title: "Sign up failed", message: "Error signing up: \(error.localizedDescription)")
            }
            throw error
        }
    }
    
    // MARK: - Sign out user
    func signOutUser() async {
        do {
            try await client.auth.signOut(scope: .local)
            
            self.lists = []
            self.currentUser = nil
            self.isSignedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            self.isSignedIn = false
        }
    }
    
    // MARK: - Reset all fields
    func resetFields() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    // MARK: - Delete user account
    func deleteAccountById(userID: String) async -> Bool {
        do {
            try await client.rpc("delete_user_by_id", params: ["user_id_param": userID])
                .execute()
                .value
            
            return true
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Error deleting account: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Verification check
    func verificationCheck(userID: String, name: String, email: String, password: String) async {
        do {
            try await client.auth.signIn(email: email, password: password)
            
            await MainActor.run {
                insertUserIntoDatabase(userID: userID, name: name, email: email)
                verificationStatus = .verified
                isSignedIn = true
            }
        } catch {
            let errorMsg = error.localizedDescription.lowercased()
            
            if errorMsg.contains("email not confirmed") || errorMsg.contains("confirmation") {
                await MainActor.run { verificationStatus = .pending }
            } else {
                await MainActor.run { verificationStatus = .error("Verification failed: \(error.localizedDescription)") }
            }
        }
    }
    
    // MARK: - Insert user into table
    func insertUserIntoDatabase(userID: String, name: String, email: String) {
        Task {
            do {
                let userData: [String: AnyJSON] = [
                    "id": .string(userID),
                    "full_name": .string(name),
                    "email": .string(email)
                ]
                
                _ = try await client
                    .from("users")
                    .insert([userData])
                    .execute()
                
                await MainActor.run {
                    isSignedIn = true
                }
            } catch {
                await MainActor.run {
                    setError(title: "Error", message: "Failed to create user record: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Check if email is valid
    func isValidEmail(email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // MARK: - Check if all fields are filled in
    func fieldsEmpty() -> Bool {
        return name.isEmpty && email.isEmpty && password.isEmpty && confirmPassword.isEmpty
    }
    
    // MARK: - Check if name is valid
    func isValidName() -> Bool {
        let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let nameRegex = "^[a-zA-Z]+(?: [a-zA-Z]+)*$"
        return trimmedName.count >= 2 && trimmedName.count <= 30 &&
        NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: trimmedName)
    }
    
    // MARK: - Check if password is valid
    func isStrongPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // MARK: - Check if passwords match
    func passwordsMatch() -> Bool {
        return password == confirmPassword
    }
    
    // MARK: - Check if sign in fields empty
    func signInFieldsempty() -> Bool {
        return email.isEmpty || password.isEmpty
    }
    
    // MARK: - Sign in user
    func signIn(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            setError(title: "Error", message: "Email and Password must be filled in.")
            return false
        }
        
        guard isValidEmail(email: email) else {
            setError(title: "Error", message: "Invalid Email")
            return false
        }
        do {
            _ = try await client.auth.signIn(email: email, password: password)
            
            let success = await initializeSession()
            
            await MainActor.run {
                self.isSignedIn = success
            }
            return success
        } catch {
            setError(title: "Login Error", message: error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Reset password
    func resetPassword() async -> Bool {
        guard !forgotPasswordEmail.isEmpty else {
            await MainActor.run {
                setError(title: "Error", message: "Email field cannot be empty.")
            }
            return false
        }
        
        guard isValidEmail(email: forgotPasswordEmail) else {
            await MainActor.run {
                setError(title: "Error", message: "Invalid email address. Please try again.")
            }
            return false
        }
        
        do {
            try await client.auth.resetPasswordForEmail(forgotPasswordEmail)
            return true
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Failed to send reset email: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Fetch user
    func fetchCurrentUser() async -> Bool {
        do {
            let session = try await client.auth.session
            
            let response: [AppUser] = try await client
                .from("users")
                .select()
                .eq("id", value: session.user.id)
                .execute()
                .value
            
            if let fetchedUser = response.first {
                self.currentUser = fetchedUser
                return true
            } else {
                setError(title: "Error", message: "User not found in database")
                return false
            }
            
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Error fetching user: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Save List with General collection
    func saveList(newList: List, generalCollection: Collection) async -> Bool {
        do {
            var listToSave = newList
            var collectionToSave = generalCollection
            
            listToSave.userId = currentUser!.id
            collectionToSave.userID = currentUser!.id
            
            try await client
                .from("list")
                .insert(listToSave)
                .execute()
            
            let success = await saveCollection(newCollection: collectionToSave)
            return success
        } catch {
            setError(title: "Error", message: "Error saving your new List: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Fetch user Lists
    func fetchUserLists() async -> Bool {
        do {
            let user = try await client.auth.user()
            let userID = user.id
            
            await MainActor.run { self.lists = [] }
            
            let response: [List] = try await client
                .from("list")
                .select()
                .eq("user_id", value: userID)
                .execute()
                .value
            
            await MainActor.run {
                self.lists = response
            }
            return true
            
        } catch {
            setError(title: "Error", message: "Error fetching your Lists: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Pin List
    func updateListPin(list: List, isPinned: Bool) async -> Bool {
        do {
            if !list.isDefault {
                try await client
                    .from("list")
                    .update(["is_pinned": isPinned])
                    .eq("id", value: list.id)
                    .execute()
            }
            
            await MainActor.run {
                if list.isDefault {
                    if let index = self.defaultLists.firstIndex(where: { $0.id == list.id }) {
                        self.defaultLists[index].isPinned = isPinned
                    }
                } else {
                    if let index = self.lists.firstIndex(where: { $0.id == list.id }) {
                        self.lists[index].isPinned = isPinned
                    }
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Delete List
    func deleteList(list: List) async -> Bool {
        do {
            try await client.from("list").delete().eq("id", value: list.id).execute()
            
            await MainActor.run {
                self.tasks.removeAll { $0.listID == list.id }
                self.notes.removeAll { $0.listID == list.id }
                self.collections.removeAll { $0.listID == list.id }
                self.lists.removeAll { $0.id == list.id }
            }
            return true
        } catch {
            await MainActor.run { self.setError(title: "Delete Failed", message: error.localizedDescription) }
            return false
        }
    }
    
    // MARK: - Update List
    func updateList(list: List, name: String, hex: String) async -> Bool {
        do {
            let updateData: [String: AnyJSON] = [
                "list_name": .string(name),
                "bg_color_hex": .string(hex)
            ]
            
            try await client
                .from("list")
                .update(updateData)
                .eq("id", value: list.id)
                .execute()
            
            await MainActor.run {
                if let index = self.lists.firstIndex(where: { $0.id == list.id }) {
                    var updatedList = self.lists[index]
                    updatedList.listName = name
                    updatedList.bgColorHex = hex
                    
                    self.lists[index] = updatedList
                }
            }
            return true
        } catch {
            print("DEBUG [UPDATE LIST] - \(error.localizedDescription)")
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Save Collection
    func saveCollection(newCollection: Collection) async -> Bool {
        do {
            var collectionToSave = newCollection
            collectionToSave.userID = currentUser!.id
            
            try await client
                .from("collection")
                .insert(collectionToSave)
                .execute()
            
            return true
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Error creating Collection, please try again. Error: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Fetch user Collections
    func fetchUserCollections() async -> Bool {
        do {
            let user = try await client.auth.user()
            let response: [Collection] = try await client
                .from("collection")
                .select()
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            await MainActor.run { self.collections = response }
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Update Collection
    func updateCollection(collection: Collection, name: String, hex: String) async -> Bool {
        do {
            let updateData: [String: AnyJSON] = [
                "collection_name": .string(name),
                "bg_color_hex": .string(hex)
            ]
            
            try await client
                .from("collection")
                .update(updateData)
                .eq("id", value: collection.id)
                .execute()
            
            await MainActor.run {
                if let index = self.collections.firstIndex(where: { $0.id == collection.id }) {
                    var updatedCollection = self.collections[index]
                    updatedCollection.collectionName = name
                    updatedCollection.bgColorHex = hex
                    
                    self.collections[index] = updatedCollection
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Delete Collection
    func deleteCollection(collection: Collection) async -> Bool {
        do {
            try await client.from("collection").delete().eq("id", value: collection.id).execute()
            
            await MainActor.run {
                self.tasks.removeAll { $0.collectionID == collection.id }
                self.notes.removeAll { $0.collectionID == collection.id }
                self.collections.removeAll { $0.id == collection.id }
            }
            return true
        } catch {
            await MainActor.run { self.setError(title: "Delete Failed", message: error.localizedDescription) }
            return false
        }
    }
    
    // MARK: - Save Task
    func saveTask(newTask: ToDoTask) async -> Bool {
        do {
            var taskToSave = newTask
            taskToSave.userID = currentUser!.id
            
            try await client
                .from("task")
                .insert(taskToSave)
                .execute()
            
            return true
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Error creating Task, please try again. Error: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Fetch user Task
    func fetchUserTasks() async -> Bool {
        do {
            let user = try await client.auth.user()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // 1. Try standard ISO8601 (2025-06-08T22:42:00Z)
                if let date = try? Date(dateString, strategy: .iso8601) {
                    return date
                }
                
                // 2. Try with fractional seconds (.123Z)
                let fractionalStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
                if let date = try? fractionalStyle.parse(dateString) {
                    return date
                }
                
                // 3. FIX: Handle naked "Timestamp without Time Zone" (2025-06-08T22:42:00)
                let nakedFormatter = DateFormatter()
                nakedFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                nakedFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Assume UTC if missing
                if let date = nakedFormatter.date(from: dateString) {
                    return date
                }
                
                // 4. Fallback for formats with space instead of T (2025-06-08 22:42:00)
                let spaceFormatter = DateFormatter()
                spaceFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                spaceFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = spaceFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
            }
            
            let response = try await client
                .from("task")
                .select()
                .eq("user_id", value: user.id)
                .execute()
            
            let tasks = try decoder.decode([ToDoTask].self, from: response.data)
            
            await MainActor.run { self.tasks = tasks }
            return true
        } catch {
            print("DEBUG [Fetch]: Task error: \(error)")
            return false
        }
    }
    
    // MARK: - Update Tasks
    func updateTask(task: ToDoTask, text: String, description: String, dueDate: Date?, isPinned: Bool) async -> Bool {
        do {
            let dueDateString: String? = {
                guard let dueDate else { return nil }
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter.string(from: dueDate)
            }()
            
            let updateData: [String: AnyJSON] = [
                "text": .string(text),
                "description": .string(description),
                "due_date": dueDateString != nil ? .string(dueDateString!) : .null,
                "is_pinned": .bool(isPinned)
            ]
            
            try await client
                .from("task")
                .update(updateData)
                .eq("id", value: task.id)
                .execute()
            
            await MainActor.run {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    self.tasks[index].text = text
                    self.tasks[index].description = description
                    self.tasks[index].dueDate = dueDate
                    self.tasks[index].isPinned = isPinned
                }
            }
            return true
            
        } catch {
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Update Pin status for Task
    func updatePinForTask(task: ToDoTask, isPinned: Bool) async -> Bool {
        do {
            let updateData: [String: AnyJSON] = [
                "is_pinned": .bool(isPinned)
            ]
            
            try await client
                .from("task")
                .update(updateData)
                .eq("id", value: task.id)
                .execute()
            
            await MainActor.run {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id } ) {
                    self.tasks[index].isPinned = isPinned
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.setError(title: "Pin Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Move Task
    func moveTask(task: ToDoTask, newCollectionID: String) async -> Bool {
        do {
            try await client
                .from("task")
                .update(["collection_id": newCollectionID])
                .eq("id", value: task.id)
                .execute()
            
            await MainActor.run {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    var updatedTask = self.tasks[index]
                    updatedTask.collectionID = newCollectionID
                    self.tasks[index] = updatedTask
                }
            }
            return true
            
        } catch {
            print("DEBUG [MOVE TASK]: \(error.localizedDescription)")
            await MainActor.run {
                self.setError(
                    title: "Move Failed",
                    message: "Failed to move Task to new Collection: \(error.localizedDescription)"
                )
            }
            return false
        }
    }
    
    // MARK: - Complete task
    func completeTask(task: ToDoTask) async -> Bool {
        do {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            
            let updateData: [String: AnyJSON] = [
                "is_completed": .bool(true),
                "date_completed": .string(timestamp)
            ]
            
            try await client
                .from("task")
                .update(updateData)
                .eq("id", value: task.id)
                .execute()
            
            await MainActor.run {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    self.tasks[index].isCompleted = true
                    self.tasks[index].dateCompleted = Date()
                }
            }
            return true
        } catch {
            print("DEBUG [Update]: \(error.localizedDescription)")
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(task: ToDoTask) async -> Bool {
        do {
            try await client
                .from("task")
                .delete()
                .eq("id", value: task.id)
                .execute()
            
            await MainActor.run {
                self.tasks.removeAll { $0.id == task.id }
            }
            
            return true
        } catch {
            await MainActor.run {
                self.setError(title: "Delete Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Save Note
    func saveNote(newNote: Note) async -> Bool {
        do {
            var noteToSave = newNote
            noteToSave.userID = currentUser!.id
            
            try await client
                .from("note")
                .insert(noteToSave)
                .execute()
            
            return true
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Error creating Note, please try again. Error: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Fetch user Notes
    func fetchUserNotes() async -> Bool {
        do {
            let user = try await client.auth.user()
            let response: [Note] = try await client
                .from("note")
                .select()
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            await MainActor.run { self.notes = response }
            return true
        } catch {
            await MainActor.run {
                setError(title: "Error", message: "Error fetching your notes: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Update Note
    func updateNote(note: Note, title: String, description: String, hex: String, isPinned: Bool) async -> Bool {
        do {
            let updateData: [String: AnyJSON] = [
                "title": .string(title),
                "description": .string(description),
                "bg_color_hex": .string(hex),
                "is_pinned": .bool(isPinned)
            ]
            
            try await client
                .from("note")
                .update(updateData)
                .eq("id", value: note.id)
                .execute()
            
            await MainActor.run {
                if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                    self.notes[index].title = title
                    self.notes[index].description = description
                    self.notes[index].bgColorHex = hex
                    self.notes[index].isPinned = isPinned
                }
            }
            return true
            
        } catch {
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Update Pin status for Note
    func updatePinForNote(note: Note, isPinned: Bool) async -> Bool {
        do {
            let updateData: [String: AnyJSON] = [
                "is_pinned": .bool(isPinned)
            ]
            
            try await client
                .from("note")
                .update(updateData)
                .eq("id", value: note.id)
                .execute()
            
            await MainActor.run {
                if let index = self.notes.firstIndex(where: { $0.id == note.id } ) {
                    self.notes[index].isPinned = isPinned
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.setError(title: "Pin Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Delete Note
    func deleteNote(note: Note) async -> Bool {
        do {
            try await client
                .from("note")
                .delete()
                .eq("id", value: note.id)
                .execute()
            
            await MainActor.run {
                self.notes.removeAll { $0.id == note.id }
            }
            
            return true
        } catch {
            await MainActor.run {
                self.setError(title: "Delete Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Move Note
    func moveNote(note: Note, newCollectionID: String) async -> Bool {
        do {
            try await client
                .from("note")
                .update(["collection_id": newCollectionID])
                .eq("id", value: note.id)
                .execute()
            
            await MainActor.run {
                if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                    var updatedNote = self.notes[index]
                    updatedNote.collectionID = newCollectionID
                    self.notes[index] = updatedNote
                }
            }
            return true
            
        } catch {
            print("DEBUG [MOVE NOTE]: \(error.localizedDescription)")
            await MainActor.run {
                self.setError(
                    title: "Move Failed",
                    message: "Failed to move Note to new Collection: \(error.localizedDescription)"
                )
            }
            return false
        }
    }
    
    // MARK: - Update user name
    func updateName(name: String) async -> Bool {
        do {
            // 1. Get the current authenticated user ID
            let authUser = try await client.auth.user()
            
            // 2. Perform the update in Supabase
            try await client
                .from("users")
                .update(["full_name": name])
                .eq("id", value: authUser.id)
                .execute()
            
            // 3. Update the local observable state immediately
            await MainActor.run {
                self.currentUser?.name = name
            }
            return true
        } catch {
            print("DEBUG [UPDATE]: \(error.localizedDescription)")
            await MainActor.run {
                self.setError(title: "Update Failed", message: error.localizedDescription)
            }
            return false
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount() async -> Bool {
        do {
            // 1. Call the Postgres RPC function to delete data and user record
            try await client.rpc("delete_user_account").execute()
            
            // 2. Sign out locally to clear the Supabase Auth session/tokens
            try await client.auth.signOut()
            
            // 3. Reset local observable state to prevent "ghost" data in the UI
            await MainActor.run {
                self.currentUser = nil
                self.lists = []
                self.tasks = []
                self.notes = []
                self.collections = []
                self.isSignedIn = false
            }
            return true
        } catch {
            print("DEBUG [Account Delete]: \(error.localizedDescription)")
            await MainActor.run {
                self.setError(
                    title: "Deletion Failed",
                    message: "We couldn't delete your account. You may need to re-authenticate (log out and back in) to perform this action."
                )
            }
            return false
        }
    }
    
    // MARK: - Fetching all user data
    func initializeSession() async -> Bool {
        do {
            // 1. Get the user from Supabase Auth
            let authUser = try await client.auth.user()
            
            // 2. Fetch the corresponding profile from your 'users' table
            let users: [AppUser] = try await client
                .from("users")
                .select()
                .eq("id", value: authUser.id)
                .execute()
                .value
            
            guard let fetchedUser = users.first else {
                print("DEBUG: Profile not found in 'users' table")
                return false
            }
            
            // 3. CRITICAL: Update the property that @main is watching
            await MainActor.run {
                self.currentUser = fetchedUser
            }
            
            async let listsLoaded = fetchUserLists()
            async let collectionsLoaded = fetchUserCollections()
            async let tasksLoaded = fetchUserTasks()
            async let notesLoaded = fetchUserNotes()
            
            let results = await [listsLoaded, collectionsLoaded, tasksLoaded, notesLoaded]
            return results.allSatisfy { $0 == true }
        } catch {
            print("DEBUG: Initialization failed: \(error)")
            return false
        }
    }
}
