//
//  TaskDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 10/04/2025.
//

import SwiftUI

//struct TaskDetailView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.dismiss) var dismiss
//    @Binding var task: Task
//    @Binding var collection: Collection
//    @ObservedObject var db: Supabase
//    @ObservedObject var helper: Helper
//    @State private var editedText: String = ""
//    @State private var editedDescription: String = ""
//    @State private var editedDueDate: Date? = nil
//    @State private var showDatePicker: Bool = false
//
//    private static var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter
//    }()
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppConstants.background(for: colorScheme)
//                    .ignoresSafeArea()
//
//                VStack(spacing: 20) {
//                    TextField("Task title...", text: $editedText)
//                        .font(.title2.bold())
//                        .foregroundColor(.primary)
//                        .padding()
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
//                        )
//
//                    TransparentTextEditor(text: $editedDescription)
//                        .padding(12)
//                        .frame(maxHeight: 250)
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
//                        )
//
//                    VStack(spacing: 12) {
//                        HStack {
//                            Text("Due Date")
//                                .font(.footnote)
//                                .foregroundColor(.secondary)
//                            Spacer()
//                            
//                            if let due = editedDueDate {
//                                Text(Self.dateFormatter.string(from: due))
//                                    .font(.footnote)
//                                    .foregroundColor(.primary)
//                            } else {
//                                Text("None")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//
//                        Button {
//                            showDatePicker.toggle()
//                        } label: {
//                            Text(editedDueDate == nil ? "Set Due Date" : "Change Due Date")
//                                .font(.subheadline)
//                                .fontWeight(.medium)
//                                .foregroundColor(.accentColor)
//                                .padding(.vertical, 8)
//                                .frame(maxWidth: .infinity)
//                                .background(.ultraThinMaterial)
//                                .clipShape(RoundedRectangle(cornerRadius: 12))
//                        }
//
//                        if showDatePicker {
//                            DatePicker("Select Date", selection: Binding(
//                                get: { editedDueDate ?? Date() },
//                                set: { editedDueDate = $0 }
//                            ), in: Date()..., displayedComponents: .date)
//                            .datePickerStyle(.graphical)
//                        }
//
//                        if editedDueDate != nil {
//                            Button(role: .destructive) {
//                                editedDueDate = nil
//                            } label: {
//                                Text("Remove Due Date")
//                                    .font(.caption)
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(.ultraThinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
//                    )
//
//                    Spacer()
//                }
//                .padding()
//            }
//            .navigationTitle("Created: \(Self.dateFormatter.string(from: task.dateCreated))")
//            .toolbarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Save") {
//                        withAnimation {
//                            task.text = editedText
//                            task.description = editedDescription
//                            task.dueDate = editedDueDate
//                        }
//                        dismiss()
//                    }
//                    .font(.headline)
//                    .foregroundColor(.accentColor)
//                }
//            }
//            .onAppear {
//                editedText = task.text
//                editedDescription = task.description ?? ""
//                editedDueDate = task.dueDate
//            }
//        }
//    }
//}

struct TaskDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var task: ToDoTask
    @Binding var collection: Collection
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var editedText: String = ""
    @State private var editedDescription: String = ""
    @State private var editedDueDate: Date? = nil
    @State private var showDatePicker: Bool = false
    @State private var animateContent: Bool = false

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background with subtle patterns
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color(UIColor.systemBackground).opacity(0.3) : Color(UIColor.systemBackground),
                        colorScheme == .dark ? Color.black.opacity(0.9) : Color(UIColor.systemBackground).opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(
                    ZStack {
                        ForEach(0..<15) { i in
                            Circle()
                                .fill(collection.bgColor.opacity(colorScheme == .dark ? 0.05 : 0.02))
                                .frame(width: CGFloat.random(in: 50...200))
                                .position(
                                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                                )
                        }
                    }
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // Task title field with visual improvements
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TASK TITLE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                                .padding(.horizontal, 4)
                            
                            TextField("Task title...", text: $editedText)
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(collection.bgColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Description editor with matching design
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                                .padding(.horizontal, 4)
                            
                            TransparentTextEditor(text: $editedDescription)
                                .placeholder(when: editedDescription.isEmpty) {
                                    Text("Add notes, details, or additional context...")
                                        .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray.opacity(0.8))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                .padding(12)
                                .frame(minHeight: 150)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(collection.bgColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Due date section with improved visuals
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DUE DATE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(collection.bgColor)
                                            .font(.system(size: 18))
                                        
                                        if let due = editedDueDate {
                                            Text(Self.dateFormatter.string(from: due))
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        } else {
                                            Text("No due date set")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            showDatePicker.toggle()
                                        }
                                    } label: {
                                        Text(editedDueDate == nil ? "Set" : "Change")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(collection.bgColor)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(collection.bgColor.opacity(0.3), lineWidth: 1)
                                )

                                if showDatePicker {
                                    VStack(spacing: 12) {
                                        DatePicker("Select Date", selection: Binding(
                                            get: { editedDueDate ?? Date() },
                                            set: { editedDueDate = $0 }
                                        ), in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(.graphical)
                                        .tint(collection.bgColor)
                                        
                                        if editedDueDate != nil {
                                            Button {
                                                withAnimation {
                                                    editedDueDate = nil
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "trash")
                                                        .font(.caption)
                                                    Text("Remove Due Date")
                                                        .font(.subheadline)
                                                }
                                                .foregroundColor(.red)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.red.opacity(0.1))
                                                )
                                            }
                                            .padding(.top, 4)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(collection.bgColor.opacity(0.3), lineWidth: 1)
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Task metadata card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("METADATA")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Label {
                                        Text("Created")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } icon: {
                                        Image(systemName: "clock")
                                            .foregroundColor(collection.bgColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(Self.dateFormatter.string(from: task.dateCreated))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Label {
                                        Text("Collection")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } icon: {
                                        Image(systemName: "folder")
                                            .foregroundColor(collection.bgColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(collection.collectionName)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(collection.bgColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Save button
                        Button {
                            withAnimation {
                                task.text = editedText
                                task.description = editedDescription
                                task.dueDate = editedDueDate
                            }
                            dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [collection.bgColor, collection.bgColor.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: collection.bgColor.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Task Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(collection.collectionName)
                            .font(.caption)
                            .foregroundColor(collection.bgColor)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.7))
                    }
                }
            }
            .onAppear {
                editedText = task.text
                editedDescription = task.description ?? ""
                editedDueDate = task.dueDate
                
                // Add entrance animation
                withAnimation(.easeOut(duration: 0.4)) {
                    animateContent = true
                }
            }
        }
    }
}

// Helper extension for placeholder text in TextEditor
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    @Previewable @State var task = ToDoTask(
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
