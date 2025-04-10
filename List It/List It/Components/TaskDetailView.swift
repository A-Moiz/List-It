//
//  TaskDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 10/04/2025.
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var task: Task
    @Binding var collection: Collection
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var editedText: String = ""
    @State private var editedDescription: String = ""
    @State private var editedDueDate: Date? = nil
    @State private var showDatePicker: Bool = false

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Task title...", text: $editedText)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                        )

                    TransparentTextEditor(text: $editedDescription)
                        .padding(12)
                        .frame(maxHeight: 250)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                        )

                    VStack(spacing: 12) {
                        HStack {
                            Text("Due Date")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                            
                            if let due = editedDueDate {
                                Text(Self.dateFormatter.string(from: due))
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                            } else {
                                Text("None")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }

                        Button {
                            showDatePicker.toggle()
                        } label: {
                            Text(editedDueDate == nil ? "Set Due Date" : "Change Due Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.accentColor)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if showDatePicker {
                            DatePicker("Select Date", selection: Binding(
                                get: { editedDueDate ?? Date() },
                                set: { editedDueDate = $0 }
                            ), in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                        }

                        if editedDueDate != nil {
                            Button(role: .destructive) {
                                editedDueDate = nil
                            } label: {
                                Text("Remove Due Date")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                    )

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Created: \(Self.dateFormatter.string(from: task.dateCreated))")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        withAnimation {
                            task.text = editedText
                            task.description = editedDescription
                            task.dueDate = editedDueDate
                        }
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.accentColor)
                }
            }
            .onAppear {
                editedText = task.text
                editedDescription = task.description ?? ""
                editedDueDate = task.dueDate
            }
        }
    }
}

#Preview {
    @Previewable @State var task = Task(
        id: UUID().uuidString,
        text: "Buy Milk",
        description: "Buy from Tesco",
        dateCreated: Date(),
        dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
        isCompleted: false,
        dateCompleted: nil,
        isDeleted: false,
        isPinned: false
    )
    @Previewable @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: [])
    TaskDetailView(task: $task, collection: $collection, db: Supabase(), helper: Helper())
}
