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
    @State var schedule: Date = Date()
    @State var addSchedule: Bool = false
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

    // MARK: - Options
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $isPinned) {
                Label("Pin Task", systemImage: "pin.fill")
                    .symbolVariant(isPinned ? .fill : .none)
            }
            
            Toggle(isOn: $addSchedule.animation()) {
                Label("Schedule reminder", systemImage: "calendar.badge.clock")
            }
            
            if addSchedule {
                DatePicker(
                    "Schedule for",
                    selection: $schedule,
                    in: Date()...,
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
            schedule: addSchedule ? schedule : nil,
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
                    scheduleNotification(at: schedule)
                    dismiss()
                }
            } else {
                showAlert = true
            }
        }
    }
    
    // MARK: - Scheduling Notification
    func scheduleNotification(at date: Date) {
        /// Content for Notification
        let content = UNMutableNotificationContent()
        content.title = taskTitle
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

#Preview {
    @Previewable @State var lists: List = List(id: UUID().uuidString, createdAt: Date(), listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
    AddTaskView(list: lists)
        .environment(Supabase())
    
    //    @Previewable @State var lists: List = List(id: UUID().uuidString, createdAt: Date(), listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
    //
    //    @Previewable @State var collectionName: String? = nil
    //
    //    TaskOrganisation(list: lists, selectedCollectionName: $collectionName)
    //        .environment(Supabase())
}
