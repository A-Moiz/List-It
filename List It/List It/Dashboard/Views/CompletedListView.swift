//
//  CompletedListView.swift
//  List It
//
//  Created by Abdul Moiz on 15/04/2025.
//

import SwiftUI

struct CompletedListView: View {
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }

    var groupedTasks: [Date: [ToDoTask]] {
        let completedTasks = (list.tasks ?? []).filter {
            $0.isCompleted && !$0.isDeleted && $0.dateCompleted != nil
        }

        return Dictionary(grouping: completedTasks) { task in
            Calendar.current.startOfDay(for: task.dateCompleted!)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                if (list.tasks ?? []).isEmpty {
                    Text("No completed tasks.")
                        .font(.title3)
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            ForEach(groupedTasks.keys.sorted(by: >), id: \.self) { date in
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 12, height: 12)

                                        Text(dateFormatter.string(from: date))
                                            .font(.headline)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                    .padding(.leading, 4)

                                    ForEach(groupedTasks[date] ?? [], id: \.id) { task in
                                        HStack(alignment: .top, spacing: 20) {
                                            VStack {
                                                Circle()
                                                    .fill(Color.green)
                                                    .frame(width: 8, height: 8)
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 2)
                                                    .frame(maxHeight: .infinity)
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(task.text)
                                                    .font(.body)
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                                if let desc = task.description, !desc.isEmpty {
                                                    Text(desc)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                HStack(spacing: 5) {
                                                    Image(systemName: "calendar")
                                                        .foregroundColor(.gray)

                                                    Text(dateFormatter.string(from: task.dateCreated))
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                            )
                                        }
                                        .padding(.leading, 8)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Completed Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let sampleTasks = [
        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: "do this", dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Date(), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Mow the lawn", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 20)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Date(), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Mow the lawn", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 20)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Date(), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Mow the lawn", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 20)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Date(), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Mow the lawn", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 20)), isDeleted: false, isPinned: false),
        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: true, dateCompleted: Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 25)), isDeleted: false, isPinned: false)
    ]
    @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), collections: [], tasks: sampleTasks, isPinned: false)
    CompletedListView(list: $list, helper: Helper(), db: Supabase())
}
