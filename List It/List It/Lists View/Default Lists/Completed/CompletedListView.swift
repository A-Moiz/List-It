//
//  CompletedListView.swift
//  List It
//
//  Created by Abdul Moiz on 15/04/2025.
//

import SwiftUI

struct CompletedListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Completion Percentage
    private var completionPercentage: Double {
        let allTasks = db.userTasks ?? []
        let activeTasks = allTasks.filter { !$0.isDeleted }
        
        guard !activeTasks.isEmpty else { return 0.0 }
        
        let completedTasks = activeTasks.filter { $0.isCompleted }
        return (Double(completedTasks.count) / Double(activeTasks.count)) * 100
    }
    
    // MARK: - Dynamic Colors
    private var progressColor: Color {
        switch completionPercentage {
        case 100:
            return .green
        case 80..<100:
            return .mint
        case 60..<80:
            return .blue
        case 40..<60:
            return .orange
        case 20..<40:
            return .yellow
        default:
            return .red
        }
    }
    
    // MARK: - Dynamic Progress bar
    private var progressGradient: LinearGradient {
        switch completionPercentage {
        case 100:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        case 80..<100:
            return LinearGradient(colors: [.mint, .cyan], startPoint: .leading, endPoint: .trailing)
        case 60..<80:
            return LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
        case 40..<60:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        case 20..<40:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    // MARK: - Grouping tasks by date
    var groupedTasks: [Date: [ToDoTask]] {
        let allTasks = db.userTasks ?? []
        let justCompletedTasks = allTasks.filter { $0.isCompleted }
        let notDeletedTasks = justCompletedTasks.filter { !$0.isDeleted }
        let withDateTasks = notDeletedTasks.filter { $0.dateCompleted != nil }

        return Dictionary(grouping: justCompletedTasks) { task in
            if let completedDate = task.dateCompleted {
                return Calendar.current.startOfDay(for: completedDate)
            } else {
                return Calendar.current.startOfDay(for: task.createdAt)
            }
        }
    }

    var body: some View {
        NavigationStack {
            // MARK: - Main view
            mainContentView
                .navigationTitle("Completed Tasks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 8) {
                            // MARK: - Completion Percentage
                            completionPercentageView
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                    }
                }
        }
    }
    
    // MARK: - Completion Percentage View
    private var completionPercentageView: some View {
        HStack(spacing: 4) {
            Text("\(Int(completionPercentage))%")
                .font(.caption.weight(.semibold))
                .foregroundColor(progressColor)
            
            ZStack(alignment: .leading) {
                // MARK: - Background
                Capsule()
                    .fill(colorScheme == .dark ? Color(.systemGray4) : Color(.systemGray5))
                    .frame(width: 30, height: 6)
                
                // MARK: - Progress
                Capsule()
                    .fill(progressColor)
                    .frame(width: 30 * (completionPercentage / 100), height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemGray6))
        )
    }
    
    // MARK: - Main view
    private var mainContentView: some View {
        ZStack {
            // MARK: - Background
            AppConstants.background(for: colorScheme)
                .ignoresSafeArea()
            
            let completedTasksExist = !(db.userTasks ?? []).filter({ $0.isCompleted }).isEmpty
            // MARK: - Empty view if no completed tasks
            if !completedTasksExist {
                EmptyStateView(
                    icon: "checklist.checked",
                    collectionColor: .green,
                    message: "Your achievements await",
                    subMessage: "Completed tasks will create your success timeline here."
                )
            } else {
                VStack(spacing: 0) {
                    // MARK: - Stats Header
                    statsHeaderView
                    
                    // MARK: - Tasks view
                    if groupedTasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text("Timeline Unavailable")
                                .font(.title3.weight(.semibold))
                            Text("Found completed tasks but couldn't display them.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        CompletedTaskList(groupedTasks: groupedTasks, dateFormatter: db.fullDateFormatter(), db: db)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Stats Header View
    private var statsHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)
                    
                    Text("Keep up the momentum!")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                // MARK: - Large percentage display
                VStack(spacing: 2) {
                    Text("\(Int(completionPercentage))%")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(progressColor)
                    
                    Text("Complete")
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
            }
            
            // MARK: - Progress bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                    .frame(height: 8)
                
                Capsule()
                    .fill(progressGradient)
                    .frame(width: max(8, UIScreen.main.bounds.width * 0.8 * (completionPercentage / 100)), height: 8)
                    .animation(.easeInOut(duration: 0.8), value: completionPercentage)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
