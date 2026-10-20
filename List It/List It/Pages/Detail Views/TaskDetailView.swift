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
    @State private var editedDueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var editedReminder: Date = Date().addingTimeInterval(60 * 60)
    @State private var hasReminder: Bool = false
    @State private var hadPendingReminder: Bool = false
    @State private var lastReminderDate: Date?
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
    private var dueDateLowerBound: Date {
        min(task.dueDate ?? Date(), Date())
    }
    private var isOverdue: Bool {
        guard hasDueDate,
              let endOfDueDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: editedDueDate)
                else { return false }
        return endOfDueDay <= Date()
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TextField("Task title", text: $editedText)
                            .font(.title3.weight(.semibold))
                        
                        Divider()
                        
                        descriptionField
                        
                        Divider()
                        
                        scheduleSection
                        
                        Divider()
                        
                        actionsRow
                    }
                    .padding(20)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Task Details")
            .toolbarTitleDisplayMode(.inline)
            .background(collection?.bgColor.opacity(0.08) ?? Color(.systemGroupedBackground))
            .onAppear {
                editedText = task.text
                editedDescription = task.description ?? ""
                isPinned = task.isPinned
                if let date = task.dueDate {
                    editedDueDate = date
                    hasDueDate = true
                }
            }
            .task {
                await loadExistingReminder()
            }
            .onChange(of: editedDueDate) { _, _ in keepReminderWithinDueDay() }
            .onChange(of: hasDueDate) { _, _ in keepReminderWithinDueDay() }
            .onChange(of: hasReminder) { _, _ in keepReminderWithinDueDay() }
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
        .frame(minHeight: 70, idealHeight: 100, maxHeight: .infinity)
    }
    
    // MARK: - Due date and reminder
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            dueDateRow
            reminderRow
            
            if isOverdue && !hasReminder {
                Text("This Task is overdue, so a reminder can't be set. Change the due date to today or later to set one.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var dueDateRow: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundStyle(collection?.bgColor ?? .blue)
            
            if hasDueDate {
                DatePicker("", selection: $editedDueDate, in: dueDateLowerBound..., displayedComponents: [.date])
                    .labelsHidden()
                    .tint(collection?.bgColor ?? .blue)
                
                Spacer()
                
                Button {
                    withAnimation {
                        hasDueDate = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No due date")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Add Due Date") {
                    withAnimation {
                        hasDueDate = true
                    }
                }
                .font(.subheadline)
                .foregroundStyle(collection?.bgColor ?? .blue)
            }
        }
    }
    
    private var reminderRow: some View {
        HStack {
            Image(systemName: "bell")
                .foregroundStyle(collection?.bgColor ?? .blue)
            
            if hasReminder {
                DatePicker("", selection: $editedReminder, in: reminderRange, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .tint(collection?.bgColor ?? .blue)
                
                Spacer()
                
                Button {
                    withAnimation {
                        hasReminder = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            } else {
                if let lastReminderDate {
                    Text("Reminded at: \(lastReminderDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("No reminder")
                        .foregroundStyle(.secondary)
                }
                
                Spacer(minLength: 8)
                
                Button(lastReminderDate == nil ? "Add Reminder" : "Remind Again") {
                    withAnimation {
                        editedReminder = Date().addingTimeInterval(60 * 60)
                        hasReminder = true
                    }
                }
                .font(.subheadline)
                .foregroundStyle(collection?.bgColor ?? .blue)
                .lineLimit(1)
                .fixedSize()
                .disabled(isOverdue)
                .opacity(isOverdue ? 0.4 : 1)
            }
        }
    }
    
    // MARK: - Reminder limits
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var reminderLimit: Date? {
        guard hasDueDate,
              let endOfDueDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: editedDueDate),
              endOfDueDay > Date() else { return nil }
        return endOfDueDay
    }
    
    private var reminderRange: ClosedRange<Date> {
        let lower = Date()
        return lower...max(lower, reminderLimit ?? Date.distantFuture)
    }
    
    private func keepReminderWithinDueDay() {
        guard hasReminder, let limit = reminderLimit, editedReminder > limit else { return }
        
        let time = calendar.dateComponents([.hour, .minute], from: editedReminder)
        let sameTimeOnDueDay = calendar.date(
            bySettingHour: time.hour ?? 0,
            minute: time.minute ?? 0,
            second: 0,
            of: editedDueDate
        ) ?? limit
        
        editedReminder = min(max(sameTimeOnDueDay, Date()), limit)
    }
    
    // MARK: - Load the reminder that is already set
    private func loadExistingReminder() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        if let request = requests.first(where: { $0.identifier == task.id }),
           let trigger = request.trigger as? UNCalendarNotificationTrigger,
           let date = trigger.nextTriggerDate() {
            await MainActor.run {
                editedReminder = date
                hasReminder = true
                hadPendingReminder = true
            }
            return
        }
        
        let remembered = await MainActor.run { ReminderStore.date(for: task.id) }
        
        if let remembered, remembered <= Date() {
            await MainActor.run {
                lastReminderDate = remembered
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
        
        // A reminder in the past is accepted by iOS and then never fires.
        if hasReminder && editedReminder <= Date() {
            db.setError(title: "Reminder", message: "Please choose a reminder time in the future.")
            alertMode = .error
            showAlert = true
            return
        }
        
        let finalDueDate = hasDueDate ? editedDueDate : nil
        let finalReminder = hasReminder ? editedReminder : nil
        let hadPending = hadPendingReminder
        let title = editedText
        
        Task {
            let success = await db.updateTask(task: task, text: editedText, description: editedDescription, dueDate: finalDueDate, isPinned: isPinned)
            if success {
                if let finalReminder {
                    scheduleNotification(taskID: task.id, title: title, at: finalReminder)
                } else if hadPending {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
                    ReminderStore.remove(for: task.id)
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
    func scheduleNotification(taskID: String, title: String, at date: Date) {
        /// Content for Notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Don't forget about this!"
        content.sound = .default
        content.userInfo = ["taskID": taskID]
        
        /// Get date components for Notification
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        /// Create Notification request. The task's id is the identifier, so the
        /// reminder can be found, replaced or cancelled later.
        let request = UNNotificationRequest(
            identifier: taskID,
            content: content,
            trigger: trigger
        )
        
        /// Status message
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                ReminderStore.set(date, for: taskID)
            }
            
            Task { @MainActor in
                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                } else {
                    statusMessage = "Task reminder scheduled for \(date.formatted(date: .abbreviated, time: .shortened))"
                }
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
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
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
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
                ReminderStore.remove(for: task.id)
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
