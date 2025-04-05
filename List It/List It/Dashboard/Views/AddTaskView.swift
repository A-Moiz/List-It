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
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    CustomTextField(icon: "plus", placeholder: "Add Task....", text: $text, isPassword: false, showPassword: false)
                    
                    HStack {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("OPTIONAL")
                            .font(.footnote)
                            .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical)
                    
                    CustomTextField(icon: "plus", placeholder: "Add description", text: $text, isPassword: false, showPassword: false)
                        .padding(.bottom)
                    
                    DatePicker("Add Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom)
                    
                    Button {
                        
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
        if isTextFilled() {
            let newTask = Task(id: UUID().uuidString, text: text, description: description, dateCreated: Date(), dueDate: dueDate, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
        } else {
            helper.showAlertWithMessage("Text field must be filled in.")
        }
    }
    
    func isTextFilled() -> Bool {
        return !text.isEmpty
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
    AddTaskView(list: $list, helper: Helper())
}
