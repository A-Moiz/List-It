//
//  ActivityView.swift
//  List It
//
//  Created by Abdul Moiz on 31/05/2025.
//

import SwiftUI

struct ActivityView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    
    private var completionRate: Double {
        let totalTasks = db.userTasks.count
        guard totalTasks > 0 else { return 0 }
        let completedTasks = db.userTasks.count(where: { $0.isCompleted })
        return Double(completedTasks) / Double(totalTasks)
    }
    
    private var pinnedTasksCount: Int {
        db.userTasks.count(where: { $0.isPinned })
    }
    
    private var overdueTasks: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return db.userTasks.count(where: { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDueDate = calendar.startOfDay(for: dueDate)
            return !task.isCompleted && taskDueDate < today
        })
    }
    
    private var tasksWithDueDates: Int {
        db.userTasks.count(where: { $0.dueDate != nil })
    }
    
    private var recentlyCompletedTasks: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return db.userTasks.count(where: { task in
            guard let completedDate = task.dateCompleted else { return false }
            return completedDate >= sevenDaysAgo
        })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            Text("Your Activity")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Overview Stats Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.blue)
                                Text("Overview")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    title: "Tasks Created",
                                    value: "\(db.userTasks.count)",
                                    color: .green
                                )
                                
                                StatCard(
                                    icon: "list.bullet.rectangle.fill",
                                    title: "Lists Created",
                                    value: "\(db.lists.count)",
                                    color: .blue
                                )
                                
                                StatCard(
                                    icon: "folder.fill",
                                    title: "Collections",
                                    value: "\(db.collections.count)",
                                    color: .orange
                                )
                                
                                StatCard(
                                    icon: "note.text",
                                    title: "Notes Created",
                                    value: "\(db.userNotes.count)",
                                    color: .purple
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Task Performance Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.green)
                                Text("Task Performance")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            // Completion Rate Progress
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Completion Rate")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(Int(completionRate * 100))%")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                
                                ProgressView(value: completionRate)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    title: "Completed",
                                    value: "\(db.userTasks.count(where: { $0.isCompleted }))",
                                    color: .green
                                )
                                
                                StatCard(
                                    icon: "clock.fill",
                                    title: "This Week",
                                    value: "\(recentlyCompletedTasks)",
                                    color: .blue
                                )
                                
                                StatCard(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Overdue",
                                    value: "\(overdueTasks)",
                                    color: .red
                                )
                                
                                StatCard(
                                    icon: "pin.fill",
                                    title: "Pinned",
                                    value: "\(pinnedTasksCount)",
                                    color: .orange
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Additional Insights Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Insights")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                InsightRow(
                                    icon: "calendar.badge.clock",
                                    title: "Tasks with Due Dates",
                                    value: "\(tasksWithDueDates)",
                                    subtitle: "out of \(db.userTasks.count) total tasks"
                                )
                                
                                InsightRow(
                                    icon: "star.fill",
                                    title: "Most Active List",
                                    value: mostActiveListName(),
                                    subtitle: "has the most tasks"
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.body)
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    private func mostActiveListName() -> String {
        guard !db.lists.isEmpty else { return "None" }
        
        let listTaskCounts = db.lists.map { list in
            (list.listName, db.userTasks.count(where: { $0.listID == list.id }))
        }
        
        let mostActive = listTaskCounts.max(by: { $0.1 < $1.1 })
        return mostActive?.0 ?? "None"
    }
}

//#Preview {
//    ActivityView()
//}
