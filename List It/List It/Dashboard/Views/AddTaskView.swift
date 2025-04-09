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
    // Task Properties
    @State var text: String = ""
    @State var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCollectionName: String? = nil
    
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
                    
                    DatePicker("Add Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom)
                    
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
        
        let newTask = Task(
            id: UUID().uuidString,
            text: text,
            description: description,
            dateCreated: Date(),
            dueDate: dueDate,
            isCompleted: false,
            dateCompleted: nil,
            isDeleted: false,
            isPinned: false
        )
        addToCollection(newTask: newTask)
        dismiss()
    }
    
    func addToCollection(newTask: Task) {
        if let name = selectedCollectionName, let index = list.collections.firstIndex(where: { $0.collectionName == name }) {
            if list.collections[index].tasks == nil {
                list.collections[index].tasks = []
            }
            list.collections[index].tasks.append(newTask)
        } else {
            if let otherIndex = list.collections.firstIndex(where: { $0.collectionName == "Other" }) {
                if list.collections[otherIndex].tasks == nil {
                    list.collections[otherIndex].tasks = []
                }
                list.collections[otherIndex].tasks.append(newTask)
            } else {
                let otherCollection = Collection(id: UUID().uuidString, collectionName: "Other", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [newTask])
                list.collections.append(otherCollection)
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
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, collections: [])
    AddTaskView(list: $list, helper: Helper())
}
