//
//  PriorityListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct PriorityListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Filters pinned tasks
    var pinnedTasksGroupedByListID: [String: [ToDoTask]] {
        let pinnedTasks = (db.userTasks ?? []).filter {
            !$0.isCompleted &&
            !$0.isDeleted &&
            $0.isPinned
        }

        return Dictionary(grouping: pinnedTasks, by: { $0.listID })
    }

    // MARK: - Map each group to its corresponding List
    var pinnedTasksByList: [(list: List, tasks: [ToDoTask])] {
        pinnedTasksGroupedByListID.compactMap { listID, tasks in
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

                if pinnedTasksByList.isEmpty {
                    EmptyStateView(icon: "pin.slash", collectionColor: list.bgColor, message: "No Priority Tasks", subMessage: "Pin important tasks to see them here.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // MARK: - Header
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Image(systemName: "pin.fill")
                                            .foregroundStyle(.orange.gradient)
                                            .font(.title3)
                                        
                                        Text("Important tasks")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text("\(pinnedTasksByList.flatMap { $0.tasks }.count)")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(.orange.gradient)
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            ForEach(pinnedTasksByList, id: \.list.id) { pair in
                                let list = pair.list
                                let tasks = pair.tasks

                                VStack(alignment: .leading, spacing: 8) {
                                    // MARK: - List header
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(accentColor(for: list).gradient)
                                            .frame(width: 3, height: 16)
                                        
                                        Text(list.listName)
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(accentColor(for: list))
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                        
                                        Spacer()
                                        
                                        Text("\(tasks.count)")
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(.white)
                                            .frame(width: 20, height: 20)
                                            .background(
                                                Circle()
                                                    .fill(accentColor(for: list).opacity(0.8))
                                            )
                                    }
                                    .padding(.horizontal, 20)

                                    ForEach(tasks, id: \.id) { task in
                                        PriorityTaskCard(
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
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Priority")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

//#Preview {
//    PriorityListView(helper: Helper(), db: Supabase())
//}
