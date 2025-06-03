//
//  Supabase.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import Foundation
import Supabase
import AuthenticationServices
import GoogleSignIn

class Supabase: ObservableObject {
    // MARK: - Properties
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
    @Published var lists: [List] = []
    @Published var userTasks: [ToDoTask] = []
    @Published var userNotes: [Note] = []
    @Published var collections: [Collection] = []
    @Published var currentUser: AppUser?
    @Published var defaultLists = [
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "sun.max", listName: "Today", isDefault: true, bgColorHex: "#FF9500", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "sunrise", listName: "Tomorrow", isDefault: true, bgColorHex: "#007AFF", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "checkmark.square.fill", listName: "Completed", isDefault: true, bgColorHex: "#34C759", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "square", listName: "Not Completed", isDefault: true, bgColorHex: "#FF3B30", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "clock.arrow.circlepath", listName: "Overdue", isDefault: true, bgColorHex: "#FF2D55", userId: "", isPinned: false),
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "flag.fill", listName: "Priority", isDefault: true, bgColorHex: "#5856D6", userId: "", isPinned: false)
    ]
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    
    init() {
        supabaseClient = SupabaseClient(supabaseURL: URL(string: Config.SUPABASE_URL)!, supabaseKey: Config.SUPABASE_KEY)
    }
    
    // MARK: - Date formatter
    func formattedDate(_ date: Date) -> String {
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Date formatter
    func dateFormatterWithoutTime(_ date: Date) -> String {
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Full date formatter
    func fullDateFormatter() -> DateFormatter {
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
        
    }
    
    // MARK: - Medium date style
    func formattedDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Date and Time
    func dateAndTime(_ date: Date) -> Date? {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let string = formatter.string(from: date)
        return formatter.date(from: string)
    }
    
    // MARK: - Sign in user
    func signInUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let response = try await client.auth.signIn(email: email, password: password)
                
                let userResponse: [AppUser] = try await client.database
                    .from("users")
                    .select()
                    .eq("id", value: response.user.id)
                    .execute()
                    .value
                
                if let fetchedUser = userResponse.first {
                    DispatchQueue.main.async {
                        self.currentUser = fetchedUser
                        completion(true, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(true, "User profile not found")
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Sign in failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Check if email already exists in database
    func checkEmailExists(email: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let response = try await client.database
                    .from("users")
                    .select("id, email")
                    .eq("email", value: email)
                    .execute()
                
                guard let jsonArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] else {
                    DispatchQueue.main.async {
                        completion(false, "Unable to verify email availability")
                    }
                    return
                }
                
                let emailExists = !jsonArray.isEmpty
                
                if emailExists {
                    DispatchQueue.main.async {
                        completion(true, "This email is already registered. Please use a different email or sign in instead.")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Network error. Please check your connection and try again.")
                }
            }
        }
    }
    
    // MARK: - Check if fields filled in
    func detailsFilled() -> Bool {
        return !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    // MARK: - Check if name is valid
    func isValidName() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameRegex = "^[a-zA-Z]+(?: [a-zA-Z]+)*$"
        return trimmedName.count >= 2 && trimmedName.count <= 30 &&
        NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: trimmedName)
    }
    
    // MARK: - Check if email is valid
    func isValidEmail() -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // MARK: - Check if password is valid
    func isStrongPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // MARK: - Checking if passwords match
    func passwordsMatch() -> Bool {
        return password == confirmPassword
    }
    
    // MARK: - Creating user
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
                    data: userMetadata,
                    redirectTo: URL(string: "https://list-it-dom.netlify.app/auth/callback")
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
    
    // MARK: - Insert user into database
    func insertUserIntoDatabase(userId: String, fullName: String, email: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let userData: [String: AnyJSON] = [
                    "id": .string(userId),
                    "full_name": .string(fullName),
                    "email": .string(email)
                ]
                
                _ = try await client.database
                    .from("users")
                    .insert([userData])
                    .execute()
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to create user record: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Logging user in
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
    
    // MARK: - Fetching current user details
    func fetchCurrentUser(completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                guard let session = try? await client.auth.session else {
                    DispatchQueue.main.async {
                        completion(false, "No active session found, you will now be signed out. Please sign in again.")
                    }
                    self.signOutUser() { success, error in
                        if !success {
                            DispatchQueue.main.async {
                                completion(false, "Error signing out user. Please sign out manually and sign in again.")
                            }
                        }
                    }
                    return
                }
                
                let userID = session.user.id
                
                let response: [AppUser] = try await client.database
                    .from("users")
                    .select()
                    .eq("id", value: userID)
                    .execute()
                    .value
                
                if let fetchedUser = response.first {
                    DispatchQueue.main.async {
                        self.currentUser = fetchedUser
                        completion(true, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "User not found in database")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Error fetching user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Saving list to DB
    func saveList(newList: List, generalCollection: Collection, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                var listToSave = newList
                listToSave.userId = userID.uuidString
                
                _ = try await client.database
                    .from("list")
                    .insert([listToSave])
                    .execute()
                
                saveCollection(newCollection: generalCollection) { succes, error in
                    if !succes {
                        completion(false, "Error creating General collection: \(error)")
                    }
                }
                
                DispatchQueue.main.async { completion(true, nil) }
            } catch {
                DispatchQueue.main.async { completion(false, "Error saving list: \(error.localizedDescription)") }
            }
        }
    }
    
    // MARK: - Saving collection
    func saveCollection(newCollection: Collection, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                var collectionToSave = newCollection
                collectionToSave.userID = userID.uuidString
                
                _ = try await client.database
                    .from("collection")
                    .insert([collectionToSave])
                    .execute()
                
                DispatchQueue.main.async { completion(true, nil) }
            } catch {
                DispatchQueue.main.async { completion(false, "Error creating Collection: \(error.localizedDescription)") }
            }
        }
    }
    
    // MARK: - Saving task
    func saveTask(newTask: ToDoTask, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                var taskToSave = newTask
                taskToSave.userID = userID.uuidString
                
                _ = try await client.database
                    .from("task")
                    .insert([taskToSave])
                    .execute()
                
                DispatchQueue.main.async { completion(true, nil) }
            } catch {
                DispatchQueue.main.async { completion(false, "Error: \(error.localizedDescription)") }
            }
        }
    }
    
    // MARK: - Fetching users Lists
    func fetchUserLists(completion: @escaping (Bool, String?) -> Void) {
        Task {
            DispatchQueue.main.async {
                self.lists = []
            }
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                let raw = try await client.database
                    .from("list")
                    .select()
                    .eq("user_id", value: userID)
                    .execute()
                
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let response = try decoder.decode([List].self, from: raw.data)
                
                DispatchQueue.main.async {
                    self.lists.append(contentsOf: response)
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Fetching user Collections
    func fetchUserCollections(completion: @escaping (Bool, String?) -> Void) {
        Task {
            DispatchQueue.main.async {
                self.collections = []
            }
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                let raw = try await client.database
                    .from("collection")
                    .select()
                    .eq("user_id", value: userID)
                    .execute()
                
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let response = try decoder.decode([Collection].self, from: raw.data)
                
                DispatchQueue.main.async {
                    self.collections.append(contentsOf: response)
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Fetching user tasks
    func fetchUserTasks(completion: @escaping (Bool, String?) -> Void) {
        Task {
            DispatchQueue.main.async {
                self.userTasks = []
            }
            
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                let raw = try await client.database
                    .from("task")
                    .select()
                    .eq("user_id", value: userID)
                    .execute()
                
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime]
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    }
                    
                    let fallbackFormatter = DateFormatter()
                    fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    if let date = fallbackFormatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode date: \(dateString)"
                    )
                }
                let response = try decoder.decode([ToDoTask].self, from: raw.data)
                
                DispatchQueue.main.async {
                    self.userTasks.append(contentsOf: response)
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Saving user note
    func saveNote(newNote: Note, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                var noteToSave = newNote
                noteToSave.userID = userID.uuidString
                
                _ = try await client.database
                    .from("note")
                    .insert([noteToSave])
                    .execute()
                
                DispatchQueue.main.async { completion(true, nil) }
            } catch {
                DispatchQueue.main.async { completion(false, "Error: \(error.localizedDescription)") }
            }
        }
    }
    
    // MARK: - Fetching user notes
    func fetchUserNotes(completion: @escaping (Bool, String?) -> Void) {
        Task {
            DispatchQueue.main.async {
                self.userNotes = []
            }
            do {
                guard let userID = try? await client.auth.session.user.id else {
                    completion(false, "No user ID found, you will now be signed out. Please sign in again.")
                    self.signOutUser() { success, error in
                        if !success {
                            completion(false, "Error signing out user. Please sign out manually and sign in again.")
                        }
                    }
                    return
                }
                
                let raw = try await client.database
                    .from("note")
                    .select()
                    .eq("user_id", value: userID)
                    .execute()
                
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let response = try decoder.decode([Note].self, from: raw.data)
                
                DispatchQueue.main.async {
                    self.userNotes.append(contentsOf: response)
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Signing out user
    func signOutUser(completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                try await client.auth.signOut()
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to sign out: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Forgot password link
    func sendResetEmail(email: String, completion: @escaping (Bool, String?) -> Void) {
        guard isEmailValid(email) else {
            DispatchQueue.main.async {
                completion(false, "Please enter a valid email address")
            }
            return
        }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.async {
                completion(false, "Email address cannot be empty")
            }
            return
        }
        
        Task {
            do {
                try await client.auth.resetPasswordForEmail(email)
                await MainActor.run {
                    completion(true, "Password reset email sent successfully. Please check your inbox.")
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to send reset email: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Check email
    private func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Updating Task
    func updateTask(task: ToDoTask, text: String, description: String, dueDate: Date?, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let formatter = ISO8601DateFormatter()
                let dueDateString = dueDate != nil ? formatter.string(from: dueDate!) : nil
                
                let _ = try await client
                    .from("task")
                    .update([
                        "text": text,
                        "description": description,
                        "due_date": dueDateString
                    ])
                    .eq("id", value: task.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userTasks.firstIndex(where: { $0.id == task.id }) {
                        self.userTasks[index].text = text
                        self.userTasks[index].description = description
                        self.userTasks[index].dueDate = dueDate
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to update Task: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Update user name
    func updateName(name: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("users")
                    .update(["full_name": name])
                    .eq("id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    self.currentUser?.fullName = name
                }
                completion(true, nil)
            } catch {
                await MainActor.run {
                    completion(false, "Failed to update user name: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Updating Note
    func updateNote(note: Note, title: String, description: String, selectedColorHex: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("note")
                    .update([
                        "title": title,
                        "description": description,
                        "bg_color_hex": selectedColorHex
                    ])
                    .eq("id", value: note.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userNotes.firstIndex(where: { $0.id == note.id }) {
                        self.userNotes[index].title = title
                        self.userNotes[index].description = description
                        self.userNotes[index].bgColorHex = selectedColorHex
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to update Note: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(task: ToDoTask, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("task")
                    .delete()
                    .eq("id", value: task.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    self.userTasks.removeAll { $0.id == task.id }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to delete Task: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Note
    func deleteNote(note: Note, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("note")
                    .delete()
                    .eq("id", value: note.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    self.userNotes.removeAll { $0.id == note.id }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to delete Note: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Collection
    func deleteCollection(collection: Collection, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("task")
                    .delete()
                    .eq("collection_id", value: collection.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                let _ = try await client
                    .from("note")
                    .delete()
                    .eq("collection_id", value: collection.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                let _ = try await client
                    .from("collection")
                    .delete()
                    .eq("id", value: collection.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    self.userTasks.removeAll { $0.collectionID == collection.id }
                    self.userNotes.removeAll { $0.collectionID == collection.id }
                    self.collections.removeAll { $0.id == collection.id }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to delete Collection: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete List
    func deleteList(list: List, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try await client.auth.session.user.id
                
                let _ = try await client
                    .from("task")
                    .delete()
                    .eq("list_id", value: list.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                let _ = try await client
                    .from("note")
                    .delete()
                    .eq("list_id", value: list.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                let _ = try await client
                    .from("collection")
                    .delete()
                    .eq("list_id", value: list.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                let _ = try await client
                    .from("list")
                    .delete()
                    .eq("id", value: list.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    self.userTasks.removeAll { $0.listID == list.id }
                    self.userNotes.removeAll { $0.listID == list.id }
                    self.collections.removeAll { $0.listID == list.id }
                    self.lists.removeAll { $0.id == list.id }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to delete List: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Move Task
    func moveTask(task: ToDoTask, newCollectionID: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("task")
                    .update([
                        "collection_id": newCollectionID,
                    ])
                    .eq("id", value: task.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userTasks.firstIndex(where: { $0.id == task.id }) {
                        self.userTasks[index].collectionID = newCollectionID
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to move Task to new Collection: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Move note
    func moveNote(note: Note, newCollectionID: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("note")
                    .update([
                        "collection_id": newCollectionID,
                    ])
                    .eq("id", value: note.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userNotes.firstIndex(where: { $0.id == note.id }) {
                        self.userNotes[index].collectionID = newCollectionID
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to move Note to new Collection: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Updating List Pin property
    func updatePinStatus(list: List, isPinned: Bool, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try await client.auth.session.user.id
                let _ = try await client
                    .from("list")
                    .update(["is_pinned": isPinned])
                    .eq("id", value: list.id)
                    .execute()
                
                await MainActor.run {
                    if let index = self.lists.firstIndex(where: { $0.id == list.id }) {
                        self.lists[index].isPinned = isPinned
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to pin List: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Updating Task Pin property
    func updateTaskPinStatus(task: ToDoTask, isPinned: Bool, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("task")
                    .update(["is_pinned": isPinned])
                    .eq("id", value: task.id)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userTasks.firstIndex(where: { $0.id == task.id }) {
                        self.userTasks[index].isPinned = isPinned
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to pin Task: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Completing Task
    func completeTask(task: ToDoTask, dateCompleted: Date, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                struct TaskUpdate: Encodable {
                    let is_completed: Bool
                    let date_completed: Date
                }
                
                let updateData = TaskUpdate(
                    is_completed: true,
                    date_completed: dateCompleted
                )
                
                let _ = try await client
                    .from("task")
                    .update(updateData)
                    .eq("id", value: task.id)
                    .eq("user_id", value: currentUserID)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userTasks.firstIndex(where: { $0.id == task.id }) {
                        self.userTasks[index].isCompleted = true
                        self.userTasks[index].dateCompleted = dateCompleted
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to mark Task as completed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Updating Note Pin property
    func updateNotePinStatus(note: Note, isPinned: Bool, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let currentUserID = try? await client.auth.session.user.id
                let _ = try await client
                    .from("note")
                    .update(["is_pinned": isPinned])
                    .eq("id", value: note.id)
                    .execute()
                
                await MainActor.run {
                    if let index = self.userNotes.firstIndex(where: { $0.id == note.id }) {
                        self.userNotes[index].isPinned = isPinned
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    completion(false, "Failed to pin Note: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let _ = try await client.rpc("delete_user_account").execute()
                
                await MainActor.run {
                    completion(true, nil)
                }
                
            } catch {
                await MainActor.run {
                    completion(false, "Error deleting account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Account by ID
    func deleteAccountById(userId: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let _ = try await client.rpc("delete_user_by_id", params: ["user_id_param": userId]).execute()
                
                await MainActor.run {
                    completion(true, nil)
                }
                
            } catch {
                await MainActor.run {
                    completion(false, "Error deleting account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Resetting input fields
    func resetFields() {
        self.name = ""
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.resetEmail = ""
    }
}
