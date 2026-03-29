//
//  OverdueView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct OverdueView: View {
    @Environment(Supabase.self) var db
    @State private var searchText: String = ""
    
    private var groupedOverdueData: [(list: List, tasks: [ToDoTask])] {
        let now = Calendar.current.startOfDay(for: Date())
        
        // 1. Filter overdue tasks
        let overdueTasks = db.tasks.filter { task in
            guard let dueDate = task.dueDate, !task.isCompleted, !task.isDeleted else { return false }
            return Calendar.current.startOfDay(for: dueDate) < now
        }
        
        // 2. Filter Lists based on search
        let cleanQuery = searchText.lowercased().replacingOccurrences(of: " ", with: "")
        let filteredLists = cleanQuery.isEmpty ? db.lists : db.lists.filter { list in
            list.listName.lowercased().replacingOccurrences(of: " ", with: "").contains(cleanQuery)
        }
        
        // 3. Group them
        return filteredLists.compactMap { list in
            let tasksInList = overdueTasks.filter { $0.listID == list.id }
            return tasksInList.isEmpty ? nil : (list: list, tasks: tasksInList)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if groupedOverdueData.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "All Caught Up" : "No Overdue Lists Found",
                        systemImage: searchText.isEmpty ? "checkmark.circle.fill" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "You have no overdue tasks." : "Try searching for a different list.")
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedOverdueData, id: \.list.id) { group in
                            Section {
                                ForEach(group.tasks) { task in
                                    OverdueTaskCard(task: task)
                                }
                            } header: {
                                HStack {
                                    Text(group.list.listName)
                                        .font(.headline.bold())
                                    Spacer()
                                    Text("\(group.tasks.count) Overdue")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.red.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Overdue")
            .toolbarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Search Lists..."
            )
        }
    }
}

// MARK: - Overdue task card
struct OverdueTaskCard: View {
    @Environment(Supabase.self) var db
    let task: ToDoTask
    
    private var collectionName: String? {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                if let collection = collectionName {
                    Label(collection.uppercased(), systemImage: "folder")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(task.text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Divider().opacity(0.3)
            
            // Footer (Creation & Due Date)
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CREATED")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.tertiary)
                    Text(task.createdAt.formatted(.dateTime.day().month().year()))
                        .font(.caption2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DUE DATE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.tertiary)
                    if let due = task.dueDate {
                        Text(due.formatted(.dateTime.day().month().year()))
                            .font(.caption2.bold())
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.red.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    //    OverdueView()
    //        .environment(Supabase())
    
    @Previewable @State var task: ToDoTask = ToDoTask(id: "", createdAt: Date(), text: "Mouse", description: "Episode 3", dueDate: Date(), isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false, userID: "", collectionID: "", listID: "")
    OverdueTaskCard(task: task)
        .environment(Supabase())
}
