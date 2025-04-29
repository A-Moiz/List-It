//
//  NotCompletedListView.swift
//  List It
//
//  Created by Abdul Moiz on 15/04/2025.
//

import SwiftUI

struct NotCompletedListView: View {
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }
    
    private var notCompletedTasks: [(task: ToDoTask, listName: String, collectionName: String)] {
        var allTasks: [(task: ToDoTask, listName: String, collectionName: String)] = []
        
        for list in db.lists {
            // Direct tasks
            if let tasks = list.tasks {
                for task in tasks {
                    allTasks.append((task: task, listName: list.listName, collectionName: "None"))
                }
            }
            
            // Tasks in collections
            for collection in list.collections {
                for task in collection.tasks {
                    allTasks.append((task: task, listName: list.listName, collectionName: collection.collectionName))
                }
            }
        }
        
        // Only tasks that are NOT completed and NOT deleted
        return allTasks.filter { taskInfo in
            !taskInfo.task.isDeleted && !taskInfo.task.isCompleted
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                mainContentView
            }
            .navigationTitle("Incomplete Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Incomplete")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Tasks you haven't completed yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(notCompletedTasks.count)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            
            Text("All tasks completed")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("You're all caught up!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(notCompletedTasks, id: \.task.id) { taskInfo in
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
            
            if notCompletedTasks.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
    }
}

#Preview {
    NotCompletedListView(helper: Helper(), db: Supabase())
}
