//
//  TaskView.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

struct TaskView: View {
    // MARK: - Properties
    @Binding var task: ToDoTask
    @Binding var collection: Collection
    @Binding var list: List
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetailView: Bool = false
    
    private var priorityColor: Color {
        if task.isPinned {
            return .yellow
        } else if let dueDate = task.dueDate, dueDate < Date() {
            return .red
        } else {
            return .clear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.text)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(task.isCompleted ? Color.gray : Color.primary)
                        .strikethrough(task.isCompleted, color: .gray)
                        .lineLimit(2)
                    
                    if let description = task.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundStyle(task.isCompleted ? Color.gray.opacity(0.7) : Color.secondary)
                            .strikethrough(task.isCompleted, color: .gray.opacity(0.5))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            // MARK: - Date info and tags
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary.opacity(0.8))
                    
                    if let dueDate = task.dueDate {
                        Text("Due \(db.dateFormatterWithoutTime(dueDate))")
                            .font(.system(size: 12))
                            .foregroundStyle(dueDate < Date() ? Color.red : Color.secondary)
                    } else {
                        Text("Created \(db.formattedDate(task.createdAt))")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
            .padding(.top, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ?
                      Color(UIColor.systemGray6) :
                        Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(priorityColor, lineWidth: priorityColor == .clear ? 0 : 2)
                )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .onTapGesture {
            showDetailView = true
        }
        .sheet(isPresented: $showDetailView) {
            TaskDetailView(task: $task, collection: $collection, db: db, helper: helper)
                .presentationDetents([.height(800)])
                .presentationCornerRadius(10)
                .interactiveDismissDisabled()
        }
        .contextMenu { contextMenuContent }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Context menu
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                db.completeTask(task: task, dateCompleted: Date()) { success, error in
                    if !success {
                        helper.showAlertWithMessage("Error marking Task as completed: \(error ?? "Unknown error")")
                    } else {
                        task.isCompleted = true
                    }
                }
            }
        } label: {
            Label(task.isCompleted ? "Mark as Incomplete" : "Complete Task", systemImage: "checkmark.circle")
        }
        
        Button {
            withAnimation {
                let newPinStatus = !task.isPinned
                db.updateTaskPinStatus(task: task, isPinned: newPinStatus) { success, error in
                    if !success {
                        helper.showAlertWithMessage("Error pinning Task: \(error ?? "Unknown error")")
                    }
                }
                task.isPinned = newPinStatus
            }
        } label: {
            Label(task.isPinned ? "Unpin Task" : "Pin Task", systemImage: "pin")
        }
        
        Menu {
            ForEach(db.collections.filter { $0.listID == list.id }) { collection in
                Button(action: {
                    withAnimation {
                        db.moveTask(task: task, newCollectionID: collection.id) { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error moving Task to new Collection: \(error)")
                            } else {
                                db.fetchUserTasks { success, errorMessage in
                                    if !success, let error = errorMessage {
                                        helper.showAlertWithMessage("Error fetching and displaying new Task: \(error)")
                                    }
                                }
                            }
                        }
                    }
                }) {
                    Text(collection.collectionName)
                }
            }
        } label: {
            Label("Move Task", systemImage: "folder")
        }
        
        Button(role: .destructive) {
            withAnimation {
                db.deleteTask(task: task) { success, error in
                    if !success {
                        helper.showAlertWithMessage("Error deleting Task: \(error ?? "Unknown error")")
                    } else {
                        db.fetchUserTasks { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching and displaying new Task: \(error)")
                            }
                        }
                    }
                }
            }
        } label: {
            Label("Delete Task", systemImage: "trash")
        }
    }
}

//#Preview {
//    @Previewable @State var task = ToDoTask(
//        id: UUID().uuidString,
//        text: "Buy Milk",
//        description: "Buy from Tesco",
//        dateCreated: Date(),
//        dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
//        isCompleted: false,
//        dateCompleted: nil,
//        isDeleted: false,
//        isPinned: false
//    )
//    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: [])
//    @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    TaskView(task: $task, collection: $collection, list: $list, db: Supabase(), helper: Helper())
//}
