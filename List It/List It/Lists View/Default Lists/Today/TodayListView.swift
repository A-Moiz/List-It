//
//  TodayListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct TodayListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Group today tasks by List ID
    var todayTasksGroupedByListID: [String: [ToDoTask]] {
        let calendar = Calendar.current
        let today = Date()
        
        let todayTasks = (db.userTasks ?? []).filter {
            !$0.isCompleted &&
            !$0.isDeleted &&
            $0.dueDate != nil &&
            calendar.isDate($0.dueDate!, inSameDayAs: today)
        }
        
        return Dictionary(grouping: todayTasks, by: { $0.listID })
    }
    
    // MARK: - Today tasks
    var todayTasksByList: [(list: List, tasks: [ToDoTask])] {
        todayTasksGroupedByListID.compactMap { listID, tasks in
            if let list = db.lists.first(where: { $0.id == listID }) {
                return (list, tasks)
            } else {
                return nil
            }
        }
        .sorted { $0.list.listName < $1.list.listName }
    }
    
    //MARK: - Accent color from list
    private func accentColor(for list: List) -> Color {
        return Color(hex: list.bgColorHex)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                if todayTasksByList.isEmpty {
                    // MARK: - Empty view
                    EmptyStateView(
                        icon: "calendar",
                        collectionColor: .orange,
                        message: "No tasks due today.",
                        subMessage: "You're all caught up for today!"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            TodayHeaderView(totalTasks: todayTasksByList.flatMap { $0.tasks }.count)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 32)
                            
                            LazyVStack(spacing: 24) {
                                ForEach(todayTasksByList, id: \.list.id) { pair in
                                    let list = pair.list
                                    let tasks = pair.tasks
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(accentColor(for: list))
                                                .frame(width: 6, height: 24)
                                            
                                            Text(list.listName)
                                                .font(.title2.weight(.bold))
                                                .foregroundColor(accentColor(for: list))
                                        }
                                        .padding(.horizontal, 4)
                                        
                                        ForEach(tasks, id: \.id) { task in
                                            TodayTaskCardView(
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
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
//#Preview {
//    TodayListView(helper: Helper(), db: Supabase())
//}
