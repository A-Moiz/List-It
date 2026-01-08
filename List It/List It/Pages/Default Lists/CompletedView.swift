//
//  CompletedView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct CompletedView: View {
    @Environment(Supabase.self) var db
    @State private var searchText: String = ""
    
    private var groupedTasks: [(date: Date, tasks: [ToDoTask])] {
        // 1. Get base completed tasks
        let completed = db.tasks.filter { $0.isCompleted }
        
        // 2. Apply search filter with relationship lookups
        let filtered = searchText.isEmpty ? completed : completed.filter { task in
            // Basic Task Data
            let matchesTask = task.text.localizedCaseInsensitiveContains(searchText) ||
            (task.description ?? "").localizedCaseInsensitiveContains(searchText)
            
            // Parent List Name Lookup
            let matchesList = db.lists.first(where: { $0.id == task.listID })?
                .listName.localizedCaseInsensitiveContains(searchText) ?? false
            
            // Parent Collection Name Lookup
            let matchesCollection = db.collections.first(where: { $0.id == task.collectionID })?
                .collectionName.localizedCaseInsensitiveContains(searchText) ?? false
            
            return matchesTask || matchesList || matchesCollection
        }
        
        // 3. Group the filtered results by start of day
        let dictionary = Dictionary(grouping: filtered) { task in
            Calendar.current.startOfDay(for: task.dateCompleted ?? task.createdAt)
        }
        
        return dictionary.keys.sorted(by: >).map { date in
            (date: date, tasks: dictionary[date] ?? [])
        }
    }
    
    private var completionPercentage: Double {
        let activeTasks = db.tasks.filter { !$0.isDeleted }
        guard !activeTasks.isEmpty else { return 0.0 }
        let completedTasks = activeTasks.filter { $0.isCompleted }
        return (Double(completedTasks.count) / Double(activeTasks.count)) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if groupedTasks.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Completed Tasks" : "No Results for \"\(searchText)\"",
                        systemImage: searchText.isEmpty ? "checklist.checked" : "magnifyingglass"
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(groupedTasks, id: \.date) { group in
                            Text(group.date.formatted(date: .long, time: .omitted))
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                                .padding(.leading, 32)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            ForEach(group.tasks) { task in
                                TimelineItemView(
                                    task: task,
                                    isLast: task.id == group.tasks.last?.id && group.date == groupedTasks.last?.date
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Completed Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Search Tasks, Collections & Lists"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(Int(completionPercentage))% Done")
                        .font(.caption2.bold())
                        .foregroundStyle(.green)
                }
            }
        }
    }
}


// MARK: - Timeline view
struct TimelineItemView: View {
    @Environment(Supabase.self) var db
    let task: ToDoTask
    let isLast: Bool
    
    private var listName: String {
        db.lists.first(where: { $0.id == task.listID })?.listName ?? "General"
    }
    
    private var collectionName: String? {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.green.gradient)
                    .frame(width: 10, height: 10)
                    .background(Circle().fill(.green.opacity(0.1)).scaleEffect(2.0))
                
                if !isLast {
                    Rectangle()
                        .fill(.green.opacity(0.3))
                        .frame(width: 2)
                }
            }
            .padding(.top, 24)
            
            CompletedTaskView(task: task, listName: listName, collectionName: collectionName)
        }
    }
}

// MARK: - Completed Task card
struct CompletedTaskView: View {
    let task: ToDoTask
    var listName: String
    var collectionName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Label(listName, systemImage: "list.bullet")
                    .font(.system(size: 10, weight: .bold))
                
                if let col = collectionName {
                    Text("•")
                    Label(col, systemImage: "folder")
                        .font(.system(size: 10, weight: .bold))
                }
                
                Spacer()
            }
            .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.text)
                    .font(.body.bold())
                
                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.bottom, 12)
    }
}

#Preview {
    CompletedView()
        .environment(Supabase())
}
