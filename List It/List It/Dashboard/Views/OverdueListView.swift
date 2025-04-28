//
//  OverdueListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct OverdueListView: View {
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }
    
    private var overdueTasks: [(task: Task, listName: String, collectionName: String)] {
        var allTasks: [(task: Task, listName: String, collectionName: String)] = []
        
        for list in db.lists {
            // Direct tasks
            if let tasks = list.tasks {
                for task in tasks {
                    allTasks.append((task: task, listName: list.listName, collectionName: "None"))
                }
            }
            
            // Tasks inside collections
            for collection in list.collections {
                for task in collection.tasks {
                    allTasks.append((task: task, listName: list.listName, collectionName: collection.collectionName))
                }
            }
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Filter: Task must have a due date, due date is before today, not completed, not deleted
        return allTasks.filter { taskInfo in
            if let dueDate = taskInfo.task.dueDate {
                return dueDate < today && !taskInfo.task.isCompleted && !taskInfo.task.isDeleted
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                mainContentView
            }
            .navigationTitle("Overdue Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Overdue")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Tasks past their due date")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(overdueTasks.count)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            
            Text("No overdue tasks")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Stay on top of your schedule!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(overdueTasks, id: \.task.id) { taskInfo in
                    TodayTaskCard(
                        task: taskInfo.task,
                        listName: taskInfo.listName,
                        collectionName: taskInfo.collectionName,
                        helper: helper,
                        db: db
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var mainContentView: some View {
        VStack(alignment: .leading) {
            headerView
            
            if overdueTasks.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
    }
}

#Preview {
    OverdueListView(helper: Helper(), db: Supabase())
}
