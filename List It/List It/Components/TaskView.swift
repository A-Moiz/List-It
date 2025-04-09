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

struct TaskView: View {
    @Binding var task: Task

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        HStack(spacing: 16) {
            // Completion toggle
            Button {
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .imageScale(.large)
            }

            // Task details
            VStack(alignment: .leading, spacing: 6) {
                Text(task.text)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .strikethrough(task.isCompleted, color: .gray)

                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .strikethrough(task.isCompleted, color: .gray)
                }

                // Date row
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let dueDate = task.dueDate {
                        Text("\(Self.dateFormatter.string(from: task.dateCreated)) - \(Self.dateFormatter.string(from: dueDate))")
                    } else {
                        Text(Self.dateFormatter.string(from: task.dateCreated))
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Pin toggle
            Button {
                task.isPinned.toggle()
            } label: {
                Image(systemName: task.isPinned ? "pin.fill" : "pin")
                    .foregroundColor(task.isPinned ? .yellow : .gray)
                    .imageScale(.medium)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
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
    TaskView(task: $task)
}
