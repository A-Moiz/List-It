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
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.system(size: 80))
                            .foregroundStyle(.orange.gradient)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("Details") {
                    TextField("Task Title", text: $taskTitle)
                    TextField("Description (optional)", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section("Organisation") {
                    TaskOrganisationRow(list: list, selectedCollectionID: $selectedCollectionID)
                }
                
                Section("Options") {
                    Toggle(isOn: $isPinned) {
                        Label("Pin Task", systemImage: "pin.fill")
                            .symbolVariant(isPinned ? .fill : .none)
                    }
                    
                    Toggle(isOn: $addDueDate.animation()) {
                        Label("Set Due Date", systemImage: "calendar.badge.clock")
                    }
                    
                    if addDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                }
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
                    dismiss()
                }
            } else {
                showAlert = true
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
