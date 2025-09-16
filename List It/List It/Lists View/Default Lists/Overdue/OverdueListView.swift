//
//  OverdueListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct OverdueListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Filter overdue tasks
    var overdueTasksGroupedByListID: [String: [ToDoTask]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let overdueTasks = (db.userTasks).filter {
            !$0.isCompleted &&
            !$0.isDeleted &&
            $0.dueDate != nil &&
            calendar.startOfDay(for: $0.dueDate!) < today
        }

        return Dictionary(grouping: overdueTasks, by: { $0.listID })
    }

    var overdueTasksByList: [(list: List, tasks: [ToDoTask])] {
        overdueTasksGroupedByListID.compactMap { listID, tasks in
            if let list = db.lists.first(where: { $0.id == listID }) {
                return (list, tasks)
            } else {
                return nil
            }
        }
        .sorted { $0.list.listName < $1.list.listName }
    }
    
    // MARK: - Accent color from list
    private func accentColor(for list: List) -> Color {
        return Color(hex: list.bgColorHex)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                if overdueTasksByList.isEmpty {
                    EmptyStateView(icon: "checkmark.seal", collectionColor: list.bgColor, message: "No overdue tasks", subMessage: "You're on top of everything!")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // MARK: - Header
                            OverdueHeader(totalTasks: overdueTasksByList.flatMap {$0.tasks}.count)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                            
                            // MARK: - Main section
                            ForEach(overdueTasksByList, id: \.list.id) { pair in
                                let list = pair.list
                                let tasks = pair.tasks

                                OverdueSection(
                                    list: list,
                                    tasks: tasks,
                                    accentColor: accentColor(for: list),
                                    colorScheme: colorScheme,
                                    db: db
                                )
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Overdue Tasks")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Calculating days overdue by
    private func daysOverdue(for task: ToDoTask) -> Int {
        guard let dueDate = task.dueDate else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: dueDateStart, to: today).day ?? 0
    }
}
//#Preview {
//    OverdueListView(helper: Helper(), db: Supabase())
//}
