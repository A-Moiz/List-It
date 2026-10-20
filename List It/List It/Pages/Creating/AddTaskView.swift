//
//  AddTaskView.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Supabase.self) var db
    @State var taskTitle: String = ""
    @State var taskDescription: String = ""
    var list: List
    @State var selectedCollectionID: String?
    @State var isPinned: Bool = false
    @State var dueDate: Date = Date()
    @State var addDueDate: Bool = false
    @State var addReminder: Bool = false
    @State var reminderDate: Date = Date().addingTimeInterval(60 * 60)
    @State var showAlert: Bool = false
    @State private var statusMessage = ""
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Task title", text: $taskTitle)
                                .font(.title3.weight(.semibold))
                            
                            descriptionField
                        }
                        
                        Divider()
                        
                        TaskOrganisationRow(list: list, selectedCollectionID: $selectedCollectionID)
                        
                        Divider()
                        
                        optionsSection
                    }
                    .padding(20)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Text("Dismiss") }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { createTask() } label: { Text("Create") }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
            .onChange(of: dueDate) { _, _ in keepReminderWithinDueDay() }
            .onChange(of: addDueDate) { _, _ in keepReminderWithinDueDay() }
            .onChange(of: addReminder) { _, _ in keepReminderWithinDueDay() }
        }
    }
    
    // MARK: - Description
    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            if taskDescription.isEmpty {
                Text("Description (optional)")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $taskDescription)
                .scrollContentBackground(.hidden)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 70, idealHeight: 100, maxHeight: .infinity)
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Spacer()
            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 36))
                .foregroundStyle(.orange)
            Spacer()
        }
    }
    
    // MARK: - Reminder limits
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var endOfDueDay: Date? {
        guard addDueDate else { return nil }
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: dueDate)
    }
    
    private var reminderRange: ClosedRange<Date> {
        let lower = Date()
        let upper = endOfDueDay ?? Date.distantFuture
        // max() because a ClosedRange with its bounds the wrong way round
        // crashes, which this screen could hit if it stays open past midnight.
        return lower...max(lower, upper)
    }
    
    private func keepReminderWithinDueDay() {
        guard let limit = endOfDueDay, reminderDate > limit else { return }
        
        let time = calendar.dateComponents([.hour, .minute], from: reminderDate)
        let sameTimeOnDueDay = calendar.date(
            bySettingHour: time.hour ?? 0,
            minute: time.minute ?? 0,
            second: 0,
            of: dueDate
        ) ?? limit
        
        reminderDate = min(max(sameTimeOnDueDay, Date()), limit)
    }
    
    // MARK: - Options
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $isPinned) {
                Label("Pin Task", systemImage: "pin.fill")
                    .symbolVariant(isPinned ? .fill : .none)
            }
            
            Toggle(isOn: $addDueDate.animation()) {
                Label("Add Due Date", systemImage: "calendar.badge.clock")
            }
            
            if addDueDate {
                DatePicker(
                    "Add Due Date",
                    selection: $dueDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
            }
            
            Toggle(isOn: $addReminder.animation()) {
                Label("Add Reminder", systemImage: "bell.badge.fill")
            }
            
            if addReminder {
                DatePicker(
                    "Add Reminder",
                    selection: $reminderDate,
                    in: reminderRange,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Check if task title is empty
    func isFieldEmpty() -> Bool {
        return taskTitle.isEmpty
    }
    
    // MARK: - Create Task
    func createTask() {
        guard !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            db.setError(title: "Error", message: "Your task must have a title.")
            showAlert = true
            return
        }
        
        if addReminder && reminderDate <= Date() {
            db.setError(title: "Reminder", message: "Please choose a reminder time in the future.")
            showAlert = true
            return
        }
        
        let collectionID: String
        if let selectedID = selectedCollectionID {
            collectionID = selectedID
        } else {
            collectionID = db.collections.first(where: {
                $0.listID == list.id && $0.collectionName == "General"
            })?.id ?? ""
        }
        
        let newTask = ToDoTask(
            id: UUID().uuidString.lowercased(),
            createdAt: Date(),
            text: taskTitle,
            description: taskDescription,
            dueDate: addDueDate ? dueDate : nil,
            isCompleted: false,
            isDeleted: false,
            isPinned: isPinned,
            userID: "",
            collectionID: collectionID,
            listID: list.id
        )
        
        Task {
            let success = await db.saveTask(newTask: newTask)
            if success {
                await MainActor.run {
                    db.tasks.append(newTask)
                    if addReminder {
                        scheduleNotification(taskID: newTask.id, title: newTask.text, at: reminderDate)
                    }
                    dismiss()
                }
            } else {
                showAlert = true
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
    }
}

// MARK: - Organisation Row
struct TaskOrganisationRow: View {
    @Environment(Supabase.self) var db
    let list: List
    @Binding var selectedCollectionID: String?
    
    var body: some View {
        Menu {
            ForEach(db.collections.filter { $0.listID == list.id }, id: \.id) { collection in
                Button {
                    selectedCollectionID = collection.id
                } label: {
                    Text(collection.collectionName)
                    Image(systemName: "folder")
                }
            }
        } label: {
            HStack {
                Label("Collection", systemImage: "folder")
                    .foregroundStyle(.primary)
                Spacer()
                Text(db.collections.first(where: { $0.id == selectedCollectionID })?.collectionName ?? "General")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Task form
struct TaskForm: View {
    @Binding var taskTitle: String
    @Binding var taskDescription: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            InputField(
                icon: "textformat",
                text: $taskTitle,
                placeholder: "What needs to be done?",
                isMultiline: false
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            
            InputField(
                icon: "doc.text",
                text: $taskDescription,
                placeholder: "Add details (optional)",
                isMultiline: true
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
    }
}

//#Preview {
//    AddTaskView()
//        .environment(Supabase())
//}
