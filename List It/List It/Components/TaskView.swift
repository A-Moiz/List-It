//
//  TaskView.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

//struct TaskView: View {
//    @Binding var task: Task
//    private static var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }()
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 5)
//                .fill(.gray.opacity(0.5))
//                .frame(height: 90)
//            
//            HStack(spacing: 20) {
//                Button {
//                    task.isCompleted.toggle()
//                } label: {
//                    Image(systemName: task.isCompleted ? "circle.fill" : "circle")
//                }
//                
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(task.text)
//                        .bold()
//                        .strikethrough(task.isCompleted)
//                    
//                    if let description = task.description, !description.isEmpty {
//                        Text(description)
//                            .font(.caption)
//                            .strikethrough(task.isCompleted)
//                    }
//                    
//                    HStack {
//                        Image(systemName: "calendar")
//                        if let dueDate = task.dueDate {
//                            Text("\(Self.dateFormatter.string(from: task.dateCreated)) - \(Self.dateFormatter.string(from: dueDate))")
//                        } else {
//                            Text(Self.dateFormatter.string(from: task.dateCreated))
//                        }
//                    }
//                    .font(.footnote)
//                }
//                
//                Spacer()
//                
//                Button {
//                    task.isPinned.toggle()
//                } label: {
//                    Image(systemName: task.isPinned ? "pin.fill" : "pin")
//                }
//            }
//            .padding()
//        }
//    }
//}

//struct TaskView: View {
//    @Binding var task: Task
//    @Binding var collection: Collection
//    @Binding var list: List
//    @ObservedObject var db: Supabase
//    @ObservedObject var helper: Helper
//
//    private static var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }()
//
//    var body: some View {
//        NavigationLink {
//            TaskDetailView(task: $task, collection: $collection, db: db, helper: helper)
//        } label: {
//            HStack(spacing: 16) {
//                Button {
//                    task.isCompleted.toggle()
//                    db.moveToCompletedList(task: task, fromList: list)
//                } label: {
//                    Image(systemName: task.isCompleted ? "square.fill" : "square")
//                        .foregroundColor(task.isCompleted ? .green : .gray)
//                        .imageScale(.large)
//                }
//
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(task.text)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                        .strikethrough(task.isCompleted, color: .gray)
//
//                    if let description = task.description, !description.isEmpty {
//                        Text(description)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .strikethrough(task.isCompleted, color: .gray)
//                    }
//
//                    HStack(spacing: 4) {
//                        Image(systemName: "calendar")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//
//                        if let dueDate = task.dueDate {
//                            Text("\(Self.dateFormatter.string(from: task.dateCreated)) - \(Self.dateFormatter.string(from: dueDate))")
//                        } else {
//                            Text(Self.dateFormatter.string(from: task.dateCreated))
//                        }
//                    }
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                }
//
//                Spacer()
//
//                Button {
//                    task.isPinned.toggle()
//                } label: {
//                    Image(systemName: task.isPinned ? "pin.fill" : "pin")
//                        .foregroundColor(task.isPinned ? .yellow : .gray)
//                        .imageScale(.medium)
//                }
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(.ultraThinMaterial)
//                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
//            )
//            .padding(.horizontal, 8)
//        }
//    }
//}

struct TaskView: View {
    @Binding var task: Task
    @Binding var collection: Collection
    @Binding var list: List
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @Environment(\.colorScheme) var colorScheme
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
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
        NavigationLink {
            TaskDetailView(task: $task, collection: $collection, db: db, helper: helper)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Task header with title and completion toggle
                HStack(alignment: .top, spacing: 14) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            task.isCompleted.toggle()
                            db.moveToCompletedList(task: task, fromList: list)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(task.isCompleted ? Color.green : Color.gray.opacity(0.5), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.text)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(task.isCompleted ? .gray : .primary)
                            .strikethrough(task.isCompleted, color: .gray)
                            .lineLimit(2)
                        
                        if let description = task.description, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(task.isCompleted ? .gray.opacity(0.7) : .secondary)
                                .strikethrough(task.isCompleted, color: .gray.opacity(0.5))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    if task.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.yellow)
                            .imageScale(.small)
                            .padding(.top, 3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                
                // Date info and tags
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.8))
                        
                        if let dueDate = task.dueDate {
                            Text("Due \(Self.dateFormatter.string(from: dueDate))")
                                .font(.system(size: 12))
                                .foregroundColor(dueDate < Date() ? .red : .secondary)
                        } else {
                            Text("Created \(Self.dateFormatter.string(from: task.dateCreated))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button {
                            withAnimation {
                                task.isPinned.toggle()
                            }
                        } label: {
                            Image(systemName: "pin")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
        }
        .buttonStyle(PlainButtonStyle())
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
    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: [])
    @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), type: .regular, collections: [], isPinned: false)
    TaskView(task: $task, collection: $collection, list: $list, db: Supabase(), helper: Helper())
}
