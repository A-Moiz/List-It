//
//  TomorrowListView.swift
//  List It
//
//  Created by Abdul Moiz on 28/04/2025.
//

import SwiftUI

struct TomorrowListView: View {
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }

    private var tomorrow: Date {
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) {
            return tomorrow
        }
        return calendar.startOfDay(for: Date()) // Fallback to today if calculation fails
    }

    // Restructured to simplify - return a simple array of task data
    private var tomorrowTasks: [(task: Task, listName: String, collectionName: String)] {
        let tomorrowDate = tomorrow
        
        var allTasks: [(task: Task, listName: String, collectionName: String)] = []
        
        // Go through each list
        for list in db.lists {
            // Check direct tasks in the list
            if let tasks = list.tasks {
                for task in tasks {
                    allTasks.append((task: task, listName: list.listName, collectionName: "None"))
                }
            }
            
            // Add tasks from collections within the list
            for collection in list.collections {
                for task in collection.tasks {
                    allTasks.append((task: task, listName: list.listName, collectionName: collection.collectionName))
                }
            }
        }
        
        // Filter tasks due tomorrow, not deleted, and not completed
        return allTasks.filter { taskInfo in
            guard let dueDate = taskInfo.task.dueDate else { return false }
            let taskDueDate = Calendar.current.startOfDay(for: dueDate)
            let isTomorrow = Calendar.current.isDate(taskDueDate, inSameDayAs: tomorrowDate)
            return isTomorrow && !taskInfo.task.isDeleted && !taskInfo.task.isCompleted
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
            .navigationTitle("Tomorrow's Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Extract header to separate view
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Tomorrow")
                    .font(.system(size: 28, weight: .bold))
                
                Text(dateFormatter.string(from: tomorrow))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(tomorrowTasks.count)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            
            Text("No tasks due tomorrow")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Looking clear ahead!")
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
                ForEach(tomorrowTasks, id: \.task.id) { taskInfo in
                    TomorrowTaskCard(
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
            
            if tomorrowTasks.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
    }
}

struct TomorrowTaskCard: View {
    let task: Task
    let listName: String
    let collectionName: String
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @State private var isCompleted: Bool
    
    init(task: Task, listName: String, collectionName: String, helper: Helper, db: Supabase) {
        self.task = task
        self.listName = listName
        self.collectionName = collectionName
        self.helper = helper
        self.db = db
        self._isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Task header
            taskHeaderView
            
            Divider()
            
            // List and collection info
            taskInfoView
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private var taskHeaderView: some View {
        HStack(alignment: .top) {
            Button(action: {
                toggleTaskCompletion()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isCompleted ? .gray : .primary)
                    .strikethrough(isCompleted)
                    .lineLimit(2)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if task.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
            }
        }
    }
    
    private var taskInfoView: some View {
        HStack {
            // List badge
            HStack(spacing: 4) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 12))
                Text(listName)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(12)
            
            // Collection badge (conditional)
            if collectionName != "None" {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.system(size: 12))
                    Text(collectionName)
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Due time (fixed to avoid compiler issues)
            timeView
        }
    }
    
    // Extract time view to fix the compiler error
    private var timeView: some View {
        Group {
            if let dueDate = task.dueDate {
                let timeString = formatTime(date: dueDate)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(timeString)
                        .font(.system(size: 12))
                }
                .foregroundColor(.red)
            } else {
                EmptyView()
            }
        }
    }
    
    // Helper function to format time
    private func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func toggleTaskCompletion() {
        // Only proceed if marking as completed (not uncompleting)
        guard !isCompleted else { return }
        
        isCompleted = true
        
        // Find the list and collection to update the task
        if let listIndex = db.lists.firstIndex(where: { $0.listName == listName }) {
            // Check if the task is in a collection
            if collectionName != "None" {
                if let collectionIndex = db.lists[listIndex].collections.firstIndex(where: { $0.collectionName == collectionName }) {
                    if let taskIndex = db.lists[listIndex].collections[collectionIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                        var updatedTask = db.lists[listIndex].collections[collectionIndex].tasks[taskIndex]
                        updatedTask.isCompleted = true
                        updatedTask.dateCompleted = Date()
                        
                        // Move to completed list
                        db.moveToCompletedList(task: updatedTask, fromList: db.lists[listIndex])
                    }
                }
            } else {
                // Check if the task is directly in the list
                if let tasks = db.lists[listIndex].tasks,
                   let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                    var updatedTask = db.lists[listIndex].tasks![taskIndex]
                    updatedTask.isCompleted = true
                    updatedTask.dateCompleted = Date()
                    
                    // Move to completed list
                    db.moveToCompletedList(task: updatedTask, fromList: db.lists[listIndex])
                }
            }
        }
        
        // Force UI refresh by triggering objectWillChange
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.db.objectWillChange.send()
        }
    }
}

#Preview {
    TomorrowListView(helper: Helper(), db: Supabase())
}
