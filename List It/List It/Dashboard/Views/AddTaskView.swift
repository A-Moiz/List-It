//
//  AddTaskView.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct AddTaskView: View {
    @Binding var list: List
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var helper: Helper
    
    @State var text: String = ""
    @State var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCollectionName: String? = nil
    @State private var addDueDate: Bool = false
    @State private var isPinned: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    CustomTextField(icon: "plus", placeholder: "Add Task....", text: $text, isPassword: false, showPassword: false)
                    
                    CustomDivider(text: "OPTIONAL")
                    
                    CustomTextField(icon: "plus", placeholder: "Add description", text: $description, isPassword: false, showPassword: false)
                        .padding(.bottom)
                    
                    Toggle(isOn: $addDueDate) {
                        Label("Set Due Date", systemImage: "calendar")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    if addDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Toggle(isOn: $isPinned) {
                        Label("Pin this task", systemImage: "pin.fill")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.bottom)
                    
                    Menu {
                        ForEach(list.collections, id: \.id) { collection in
                            Button(action: {
                                selectedCollectionName = collection.collectionName
                            }) {
                                HStack {
                                    Text(collection.collectionName)
                                    if selectedCollectionName == collection.collectionName {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCollectionName ?? "Select Collection")
                                .foregroundColor(selectedCollectionName == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button {
                        createTask()
                    } label: {
                        ButtonView(text: "Create Task", icon: "arrow.right")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    func createTask() {
        guard isTextFilled() else {
            helper.showAlertWithMessage("Text field must be filled in.")
            return
        }
        
        let newTask = ToDoTask(
            id: UUID().uuidString,
            text: text,
            description: description,
            dateCreated: Date(),
            dueDate: addDueDate ? dueDate : nil,
            isCompleted: false,
            dateCompleted: nil,
            isDeleted: false,
            isPinned: isPinned
        )
        addToCollection(newTask: newTask)
        dismiss()
    }
    
    func addToCollection(newTask: ToDoTask) {
        if let name = selectedCollectionName, let index = list.collections.firstIndex(where: { $0.collectionName == name }) {
            if list.collections[index].tasks == nil {
                list.collections[index].tasks = []
            }
            list.collections[index].tasks.append(newTask)
        } else {
            if let generalIndex = list.collections.firstIndex(where: { $0.collectionName == "General" }) {
                if list.collections[generalIndex].tasks == nil {
                    list.collections[generalIndex].tasks = []
                }
                list.collections[generalIndex].tasks.append(newTask)
            } else {
                let generalCollection = Collection(id: UUID().uuidString, collectionName: "General", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [newTask])
                list.collections.append(generalCollection)
            }
        }
        for collection in list.collections {
            print("Collection Name: \(collection.collectionName), Tasks Count: \(collection.tasks.count)\nTasks in Collection: \(collection.tasks)")
        }
    }
    
    func isTextFilled() -> Bool {
        return !text.isEmpty
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), collections: [], isPinned: false)
    AddTaskView(list: $list, helper: Helper())
}
