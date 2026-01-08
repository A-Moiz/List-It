//
//  PriorityView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct PriorityView: View {
    @Environment(Supabase.self) var db
    @State private var searchText: String = ""

    private var groupedPriorityData: [(list: List, tasks: [ToDoTask])] {
        // 1. Get all uncompleted pinned tasks
        let allPinned = db.tasks.filter { $0.isPinned && !$0.isCompleted && !$0.isDeleted }
        
        // 2. Normalize search query
        let cleanQuery = searchText.lowercased().replacingOccurrences(of: " ", with: "")
        
        // 3. Filter Lists based on search, then map to their pinned tasks
        let filteredLists = cleanQuery.isEmpty ? db.lists : db.lists.filter {
            $0.listName.lowercased().replacingOccurrences(of: " ", with: "").contains(cleanQuery)
        }
        
        return filteredLists.compactMap { list in
            let tasksInList = allPinned.filter { $0.listID == list.id }
            return tasksInList.isEmpty ? nil : (list: list, tasks: tasksInList)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if groupedPriorityData.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Pinned Tasks" : "No Lists Match \"\(searchText)\"",
                        systemImage: searchText.isEmpty ? "pin.slash" : "magnifyingglass"
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedPriorityData, id: \.list.id) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(group.list.bgColor)
                                    
                                    Text(group.list.listName)
                                        .font(.headline.bold())
                                    
                                    Spacer()
                                    
                                    Text("\(group.tasks.count)")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal)

                                ForEach(group.tasks) { task in
                                    PriorityTaskCard(task: task)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Priority")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Search Lists..."
            )
        }
    }
}


// MARK: - Priority card view
struct PriorityTaskCard: View {
    @Environment(Supabase.self) var db
    let task: ToDoTask
    
    private var collectionName: String? {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let collection = collectionName {
                    Label(collection.uppercased(), systemImage: "folder.fill")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.text)
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                
                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            HStack {
                Text("Created \(task.createdAt.formatted(.dateTime.day().month()))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                if let due = task.dueDate {
                    Label(due.formatted(.dateTime.day().month()), systemImage: "clock")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(due < Date() ? .red : .primary)
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
        .padding(.horizontal)
    }
}

#Preview {
    PriorityView()
        .environment(Supabase())
}
