//
//  NotCompletedListView.swift
//  List It
//
//  Created by Abdul Moiz on 15/04/2025.
//

import SwiftUI

struct NotCompletedListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Grouping tasks by list ID
    var notCompletedTasksGroupedByListID: [String: [ToDoTask]] {
        let incompleteTasks = (db.userTasks ?? []).filter {
            !$0.isCompleted && !$0.isDeleted
        }

        return Dictionary(grouping: incompleteTasks, by: { $0.listID })
    }

    // MARK: - Not completed tasks
    var notCompletedTasksByList: [(list: List, tasks: [ToDoTask])] {
        notCompletedTasksGroupedByListID.compactMap { listID, tasks in
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

                if (db.userTasks ?? []).filter({ !$0.isCompleted && !$0.isDeleted }).isEmpty {
                    EmptyStateView(
                        icon: "checklist.unchecked",
                        collectionColor: .gray,
                        message: "No pending tasks.",
                        subMessage: "Create new tasks to stay productive."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(notCompletedTasksByList, id: \.list.id) { pair in
                                let list = pair.list
                                let tasks = pair.tasks

                                VStack(alignment: .leading, spacing: 12) {
                                    // MARK: - List header
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(accentColor(for: list))
                                            .frame(width: 6, height: 24)
                                        
                                        Text(list.listName)
                                            .font(.title2.weight(.bold))
                                            .foregroundColor(accentColor(for: list))
                                        
                                        Spacer()
                                        
                                        Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s")")
                                            .font(.caption.weight(.medium))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemGray6))
                                            )
                                    }
                                    .padding(.horizontal, 4)

                                    ForEach(tasks, id: \.id) { task in
                                        IncompleteTaskCard(
                                            task: task,
                                            list: list,
                                            listAccentColor: accentColor(for: list),
                                            colorScheme: colorScheme,
                                            db: db
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("To-Do")
            .toolbarTitleDisplayMode(.large)
        }
    }
}

//#Preview {
//    NotCompletedListView(helper: Helper(), db: Supabase())
//}
