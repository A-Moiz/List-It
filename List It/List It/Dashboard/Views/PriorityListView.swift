//
//  PriorityListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct PriorityListView: View {
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }
    
    private var pinnedTasks: [(task: ToDoTask, listName: String, collectionName: String)] {
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
        
        // Only pinned, not deleted, and not completed
        return allTasks.filter { taskInfo in
            taskInfo.task.isPinned && !taskInfo.task.isDeleted && !taskInfo.task.isCompleted
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                // Break down into smaller components to help type checking
                mainContentView
            }
            .navigationTitle("Priority Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Extract header to separate view
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Priorities")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Important tasks at a glance")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(pinnedTasks.count)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "pin.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            
            Text("No pinned tasks")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Pin tasks you find important!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // Task list view
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(pinnedTasks, id: \.task.id) { taskInfo in
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
    
    // Combine all views
    private var mainContentView: some View {
        VStack(alignment: .leading) {
            headerView
            
            if pinnedTasks.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
    }
}

#Preview {
    PriorityListView(helper: Helper(), db: Supabase())
}
