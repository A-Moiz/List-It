//
//  AddTaskView.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct AddTaskView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State var text: String = ""
    @State var description: String = ""
    @State var dueDate: Date?
    @State var isPinned: Bool = false
    @State var selectedCollectionName: String?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var addDueDate: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            Text("Create New Task")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Task Content Card
                        VStack(spacing: 20) {
                            // MARK: - Task Title
                            InputField(
                                icon: "textformat",
                                placeholder: "What needs to be done?",
                                text: $text
                            )
                            
                            // MARK: - Task Description
                            InputField(
                                icon: "doc.text",
                                placeholder: "Add details (optional)",
                                text: $description,
                                isMultiline: true
                            )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Organization Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "folder.badge.gearshape")
                                    .foregroundColor(.blue)
                                Text("Organization")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            // MARK: - Collection Selector
                            Menu {
                                ForEach(db.collections.filter { $0.listID == list.id }, id: \.id) { collection in
                                    Button(action: {
                                        selectedCollectionName = collection.collectionName
                                    }) {
                                        HStack {
                                            Image(systemName: "folder")
                                            Text(collection.collectionName)
                                            if selectedCollectionName == collection.collectionName {
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "folder")
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Collection")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(selectedCollectionName ?? "General")
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Options Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.purple)
                                Text("Options")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            // MARK: - Pin Toggle
                            ToggleRow(
                                icon: "pin.fill",
                                title: "Pin Task",
                                subtitle: "Keep at the top of your list",
                                isOn: $isPinned,
                                accentColor: .orange
                            )
                            
                            // MARK: - Due Date Toggle
                            ToggleRow(
                                icon: "calendar.badge.clock",
                                title: "Set Due Date",
                                subtitle: "Add a deadline for this task",
                                isOn: $addDueDate,
                                accentColor: .blue
                            )
                            .onChange(of: addDueDate) { newValue in
                                if newValue && dueDate == nil {
                                    dueDate = Date()
                                } else if !newValue {
                                    dueDate = nil
                                }
                            }
                            
                            // MARK: - Due Date Picker
                            if addDueDate {
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.blue)
                                        Text("Due Date")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }
                                    
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: { dueDate ?? Date() },
                                            set: { dueDate = $0 }
                                        ),
                                        in: Date()...,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(CompactDatePickerStyle())
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: addDueDate)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Create Button
                        Button(action: createTask) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Create Task")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                            .scaleEffect(1.0)
                        }
                        .buttonStyle(PressedButtonStyle())
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Cancel")
                                .font(.body)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Create Task function
    func createTask() {
        guard !text.isEmpty else {
            helper.showAlertWithMessage("Task title is required.")
            return
        }
        
        let matchedCollection = db.collections.first {
            $0.collectionName == (selectedCollectionName ?? "General") && $0.listID == list.id
        }
        
        let trimmedDate = AppConstants.trimmedToMinute(Date()) ?? Date()
        let newTask = ToDoTask(
            id: UUID().uuidString,
            createdAt: trimmedDate,
            text: text,
            description: description,
            dueDate: addDueDate ? dueDate : nil,
            isCompleted: false,
            dateCompleted: nil,
            isDeleted: false,
            isPinned: isPinned,
            userID: "",
            collectionID: matchedCollection?.id ?? "",
            listID: list.id
        )
        
        db.saveTask(newTask: newTask) { success, errorMessage in
            if !success {
                helper.showAlertWithMessage("Error creating Task: \(errorMessage)")
            } else {
                db.fetchUserTasks { success, errorMessage in
                    if !success, let error = errorMessage {
                        helper.showAlertWithMessage("Error fetching new task: \(error)")
                    }
                }
                dismiss()
            }
        }
    }
}

//#Preview {
//    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    AddTaskView(list: $list, helper: Helper())
//}
