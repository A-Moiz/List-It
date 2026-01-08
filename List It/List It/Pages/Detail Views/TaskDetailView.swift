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
    @State private var showPicker: Bool = false
    @State private var isPinned: Bool = false
    @State var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    
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
            Form {
                Section("Task Title") {
                    TextField("What needs to be done?", text: $editedText)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Description") {
                    TextEditor(text: $editedDescription)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Schedule") {
                    HStack {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Due Date")
                                if hasDueDate {
                                    Text(editedDueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("No due date set")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundStyle(collection?.bgColor ?? .blue)
                        }
                        
                        Spacer()

                        Button(hasDueDate ? "Change" : "Set") {
                            withAnimation {
                                if !hasDueDate { hasDueDate = true }
                                showPicker.toggle()
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(collection?.bgColor ?? .blue)
                    }
                    
                    if showPicker {
                        DatePicker(
                            "Select Date",
                            selection: $editedDueDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(collection?.bgColor ?? .blue)
                        
                        if hasDueDate {
                            Button("Remove Due Date", role: .destructive) {
                                withAnimation {
                                    hasDueDate = false
                                    showPicker = false
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Actions") {
                    Button {
                        isPinned.toggle()
                    } label: {
                        Label(isPinned ? "Unpin Task" : "Pin Task", systemImage: isPinned ? "pin.fill" : "pin")
                            .symbolEffect(.bounce, value: isPinned)
                    }
                    .tint(.orange)
                    
                    Button {
                        completeTask()
                    } label: {
                        Label("Mark as Completed", systemImage: "checkmark.circle")
                    }
                    .tint(.green)
                    
                    Button(role: .destructive) {
                        alertMode = .delete
                        showAlert = true
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                    }
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
            }
            .navigationTitle("Task Details")
            .toolbarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(collection?.bgColor.opacity(0.3) ?? Color(.systemGroupedBackground))
            .onAppear {
                editedText = task.text
                editedDescription = task.description ?? ""
                isPinned = task.isPinned
                if let date = task.dueDate {
                    editedDueDate = date
                    hasDueDate = true
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
        
        let finalDueDate = hasDueDate ? editedDueDate : nil
        
        Task {
            let success = await db.updateTask(task: task, text: editedText, description: editedDescription, dueDate: finalDueDate, isPinned: isPinned)
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

#Preview {
    @Previewable @State var task: ToDoTask = ToDoTask(id: "", createdAt: Date(), text: "Mouse", description: "Episode 3", dueDate: Date(), isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false, userID: "", collectionID: "", listID: "")
    
    TaskDetailView(task: task)
        .environment(Supabase())
}

