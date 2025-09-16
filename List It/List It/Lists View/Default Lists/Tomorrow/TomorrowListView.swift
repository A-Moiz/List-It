//
//  TomorrowListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct TomorrowListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Filter tomorrow tasks by List ID
    var tomorrowTasksGroupedByListID: [String: [ToDoTask]] {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!

        let tomorrowTasks = (db.userTasks).filter {
            !$0.isCompleted &&
            !$0.isDeleted &&
            $0.dueDate != nil &&
            calendar.isDate($0.dueDate!, inSameDayAs: tomorrow)
        }

        return Dictionary(grouping: tomorrowTasks, by: { $0.listID })
    }

    // MARK: - Filter tomorrow tasks
    var tomorrowTasks: [(list: List, tasks: [ToDoTask])] {
        tomorrowTasksGroupedByListID.compactMap { listID, tasks in
            if let list = db.lists.first(where: { $0.id == listID }) {
                return (list, tasks)
            } else {
                return nil
            }
        }
        .sorted { $0.list.listName < $1.list.listName }
    }
    
    // MARK: - accent color for list
    private func accentColor(for list: List) -> Color {
        return Color(hex: list.bgColorHex)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                if tomorrowTasks.isEmpty {
                    // MARK: - Empty view
                    EmptyStateView(icon: "calendar.badge.plus", collectionColor: list.bgColor, message: "Tomorrow Awaits", subMessage: "Ready for a fresh start")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            TomorrowHeaderView(totalTasks: tomorrowTasks.flatMap { $0.tasks }.count)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 32)
                            
                            ForEach(tomorrowTasks, id: \.list.id) { pair in
                                let list = pair.list
                                let tasks = pair.tasks

                                TomorrowListSection(
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
            .navigationTitle("Tomorrow")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

//#Preview {
//    TomorrowListView(helper: Helper(), db: Supabase())
//}
