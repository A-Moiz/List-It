//
//  NotCompletedView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct NotCompletedView: View {
    @Environment(Supabase.self) var db
    @State private var searchText: String = ""
    
    private var groupedData: [(list: List, tasks: [ToDoTask])] {
        // 1. Filter lists based on search text
        let filteredLists = searchText.isEmpty ? db.lists : db.lists.filter {
            $0.listName.localizedCaseInsensitiveContains(searchText)
        }
        
        // 2. Map filtered lists to their uncompleted tasks
        return filteredLists.compactMap { list in
            let uncompletedTasks = db.tasks.filter {
                $0.listID == list.id && !$0.isCompleted && !$0.isDeleted
            }
            
            // Only return the list if it has pending tasks
            return uncompletedTasks.isEmpty ? nil : (list: list, tasks: uncompletedTasks)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if groupedData.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "All Caught Up!" : "No Lists Found",
                        systemImage: searchText.isEmpty ? "checkmark.seal.fill" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "You have no pending tasks." : "Try a different list name.")
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedData, id: \.list.id) { group in
                            Section {
                                ForEach(group.tasks) { task in
                                    PendingTaskCard(task: task)
                                }
                            } header: {
                                HStack {
                                    Text(group.list.listName)
                                        .font(.title3.bold())
                                    Text("\(group.tasks.count)")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(group.list.bgColor))
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Pending Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Search Lists..."
            )
        }
    }
}

// MARK: - Not Completed Tasks card
struct PendingTaskCard: View {
    @Environment(Supabase.self) var db
    let task: ToDoTask
    
    private var collectionName: String? {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Source Metadata (List & Collection)
            if let collection = collectionName {
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                    Text(collection)
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                }
                .foregroundStyle(.secondary)
                .padding(.bottom, -4)
            }

            // Title & Description
            VStack(alignment: .leading, spacing: 4) {
                Text(task.text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Divider().opacity(0.3)
            
            // Dates Row
            HStack {
                Label(task.createdAt.formatted(.dateTime.day().month().year()), systemImage: "calendar.badge.plus")
                
                Spacer()
                
                if let dueDate = task.dueDate {
                    Label(dueDate.formatted(.dateTime.day().month()), systemImage: "clock")
                        .foregroundStyle(dueDate < Date() ? .red : .blue)
                        .font(.caption.bold())
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NotCompletedView()
        .environment(Supabase())
}
