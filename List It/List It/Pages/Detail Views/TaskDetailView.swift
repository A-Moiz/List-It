//
//  TaskDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    var task: ToDoTask
    
    @State private var editedText: String = ""
    @State private var editedDescription: String = ""
    @State private var editedSchedule: Date = Date()
    @State private var hasSchedule: Bool = false
    @State private var showPicker: Bool = false
    @State private var isPinned: Bool = false
    @State var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    @State private var statusMessage = ""
    
    private var collection: Collection? {
        db.collections.first(where: { $0.id == task.collectionID })
    }
    
    private var alertTitle: String {
        alertMode == .delete ? "Delete Task?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Task title", text: $editedText)
                        .font(.title3.weight(.semibold))
                    
                    Divider()
                    
                    descriptionField
                    
                    Divider()
                    
                    scheduleRow
                    
                    Divider()
                    
                    actionsRow
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Task Details")
            .toolbarTitleDisplayMode(.inline)
            .background(collection?.bgColor.opacity(0.08) ?? Color(.systemGroupedBackground))
            .onAppear {
                editedText = task.text
                editedDescription = task.description ?? ""
                isPinned = task.isPinned
                if let date = task.schedule {
                    editedSchedule = date
                    hasSchedule = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .fontWeight(.bold)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                if alertMode == .delete {
                    Button("Delete", role: .destructive) {
                        performDelete()
                    }
                    Button("Cancel", role: .cancel) { }
                } else {
                    Button("OK", role: .cancel) { }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Description
    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            if editedDescription.isEmpty {
                Text("Add a description")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $editedDescription)
                .scrollContentBackground(.hidden)
        }
        .frame(minHeight: 70, maxHeight: 100)
    }

    // MARK: - Schedule
    private var scheduleRow: some View {
        VStack {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(collection?.bgColor ?? .blue)
                
                if hasSchedule {
                    DatePicker("", selection: $editedSchedule, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .tint(collection?.bgColor ?? .blue)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            hasSchedule = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No due date")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Set Date") {
                        withAnimation {
                            hasSchedule = true
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(collection?.bgColor ?? .blue)
                }
            }
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions
    private var actionsRow: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation {
                    isPinned.toggle()
                }
            } label: {
                Label(isPinned ? "Unpin" : "Pin", systemImage: isPinned ? "pin.fill" : "pin")
                    .symbolEffect(.bounce, value: isPinned)
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            
            Button {
                alertMode = .delete
                showAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            Spacer()
            
            Button {
                completeTask()
            } label: {
                Label("Complete", systemImage: "checkmark.circle.fill")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(collection?.bgColor ?? .blue)
        }
    }
    
    // MARK: - Check if text is empty
    func isFieldEmpty() -> Bool {
        return editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Save changes
    func saveChanges() {
        guard !isFieldEmpty() else {
            db.setError(title: "Error", message: "Your Task must have a title.")
            alertMode = .error
            showAlert = true
            return
        }
        
        let finalSchedule = hasSchedule ? editedSchedule : nil
        
        Task {
            let success = await db.updateTask(task: task, text: editedText, description: editedDescription, schedule: finalSchedule, isPinned: isPinned)
            if success {
                if let finalSchedule {
                    scheduleNotification(at: finalSchedule)
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
                }
                await MainActor.run { dismiss() }
            } else {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
    
    // MARK: - Scheduling Notification
    func scheduleNotification(at date: Date) {
        /// Content for Notification
        let content = UNMutableNotificationContent()
        content.title = editedText
        content.body = "Don't forget about this!"
        content.sound = .default
        
        /// Get date components for Notification
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        /// Create Notification request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        /// Status message
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                statusMessage = "Error: \(error.localizedDescription)"
            } else {
                statusMessage = "Task reminder scheduled for \(date.formatted(date: .abbreviated, time: .shortened))"
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending: \(requests.count)")
        }
    }
    
    // MARK: - Complete Task
    func completeTask() {
        Task {
            let success = await db.completeTask(task: task)
            
            if success {
                await MainActor.run {
                    dismiss()
                }
            } else {
                await MainActor.run {
                    showAlert = true
                }
            }
        }
    }
    
    // MARK: - Delete Task
    func performDelete() {
        Task {
            let success = await db.deleteTask(task: task)
            if success {
                await MainActor.run { dismiss() }
            } else {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
}

//#Preview {
//    TaskDetailView()
//        .environment(Supabase())
//}

