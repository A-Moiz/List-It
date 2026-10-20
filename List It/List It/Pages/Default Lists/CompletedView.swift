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
    @State private var showAlert: Bool = false
    @State private var selectedListID: String? = nil
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    
    private var groupedTasks: [(date: Date, tasks: [ToDoTask])] {
        /// 1. Get base completed tasks
        var completed = db.tasks.filter { $0.isCompleted }
        
        /// 2. Filter by dropdown List selection if a specific list is chosen
        if let selectedListID {
            completed = completed.filter { $0.listID == selectedListID }
        }
        
        /// 3. Trim whitespace/newlines and apply search filter
        let cleanedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let filtered: [ToDoTask]
        if cleanedSearchText.isEmpty {
            filtered = completed
        } else {
            /// PRE-MAPPING: Create a quick [ID: Collection] lookup table once
            let collectionsByID = Dictionary(uniqueKeysWithValues: db.collections.map { ($0.id, $0) })
            
            filtered = completed.filter { task in
                /// Instant O(1) dictionary lookup instead of searching the whole array
                return collectionsByID[task.collectionID]?
                    .collectionName.localizedCaseInsensitiveContains(cleanedSearchText) ?? false
            }
        }
        
        /// 4. Group the filtered results by start of day
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
    
    private var selectedListTitle: String {
        guard let selectedListID else { return "All Lists" }
        return db.lists.first(where: { $0.id == selectedListID })?.listName ?? "All Lists"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                listsMenu
                
                Divider()
                    .padding(.horizontal)
                    .padding(.top)
                
                if groupedTasks.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Completed Tasks" : "No Results for \"\(searchText)\"",
                        systemImage: searchText.isEmpty ? "checklist.checked" : "magnifyingglass"
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(groupedTasks, id: \.date) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                dayHeader(for: group)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    let tasksArray = Array(group.tasks.enumerated())
                                    
                                    ForEach(tasksArray, id: \.element.id) { index, task in
                                        TimelineView(
                                            task: task,
                                            isLast: index == tasksArray.count - 1,
                                            onUndo: { uncomplete(task) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Completed Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Search Collections"
            )
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(Int(completionPercentage))% Done")
                        .font(.caption2.bold())
                        .foregroundStyle(.green)
                }
            }
            .alert(db.alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(db.alertMessage)
            }
        }
    }
    
    // MARK: - List Menu
    private var listsMenu: some View {
        Menu {
            Button(action: { selectedListID = nil }) {
                HStack {
                    Text("All Lists")
                    if selectedListID == nil { Image(systemName: "checkmark") }
                }
            }
            
            Divider()
            
            ForEach(db.lists, id: \.id) { list in
                Button(action: { selectedListID = list.id }) {
                    HStack {
                        Text(list.listName)
                        if selectedListID == list.id { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedListTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Day header
    private func dayHeader(for group: (date: Date, tasks: [ToDoTask])) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(dayTitle(for: group.date))
                .font(.system(.subheadline, design: .default))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text("\(group.tasks.count) completed")
                .font(.footnote)
                .foregroundStyle(.tertiary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Date title
    private func dayTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
    
    // MARK: - Undo
    private func uncomplete(_ task: ToDoTask) {
        Task {
            let success = await db.uncompleteTask(task: task)
            
            if success {
                let remembered = await MainActor.run { ReminderStore.date(for: task.id) }
                if let remembered, remembered > Date() {
                    ReminderStore.remove(for: task.id)
                }
            } else {
                await MainActor.run { showAlert = true }
            }
        }
    }
}

// MARK: - Timeline view
struct TimelineView: View {
    @Environment(Supabase.self) var db
    let task: ToDoTask
    let isLast: Bool
    let onUndo: () -> Void
    private var parentList: List? {
        db.lists.first(where: { $0.id == task.listID })
    }
    private var parentCollection: Collection? {
        db.collections.first(where: { $0.id == task.collectionID })
    }
    private var canUndo: Bool {
        guard let completed = task.dateCompleted else { return false }
        return Calendar.current.isDateInToday(completed)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .stroke(parentList?.bgColor ?? Color.green, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .background(Circle().fill(Color(.systemBackground)))
                    .padding(.top, 4)
                
                if !isLast {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 1)
                        .frame(minHeight: 28)
                        .padding(.vertical, 2)
                }
            }
            .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 12) {
                    Text(task.text)
                        .font(.system(.body))
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if let completedDate = task.dateCompleted {
                        Text(completedDate.formatted(.dateTime.hour().minute()))
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(parentList?.listName ?? "General")
                        .foregroundStyle(.secondary)
                    
                    if let collectionName = parentCollection?.collectionName {
                        Text("/")
                            .foregroundStyle(.tertiary)
                        Text(collectionName)
                            .foregroundStyle(.tertiary)
                    }
                }
                .font(.footnote)
            }
            .padding(.bottom, isLast ? 8 : 16)
            
            if canUndo {
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.footnote.bold())
                        .foregroundStyle(.tertiary)
                        .padding(6)
                        .background(Color(.systemFill).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .padding(.top, -2)
            }
        }
    }
}


// MARK: - Completed Task card
struct CompletedTaskView: View {
    @Environment(\.colorScheme) private var colorScheme
    let task: ToDoTask
    var listName: String
    var collectionName: String?
    var accent: Color
    var canUndo: Bool
    var onUndo: () -> Void
    private let cornerRadius: CGFloat = 12
    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.text)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(2)
                    
                    if let desc = task.description, !desc.isEmpty {
                        Text(desc)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer(minLength: 8)
                
                if canUndo {
                    Button {
                        onUndo()
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(accent)
                }
            }
            
            footer
        }
        .padding(12)
        .background(
            cardShape.fill(
                colorScheme == .dark
                ? Color(.secondarySystemGroupedBackground)
                : Color.white
            )
        )
        .overlay {
            cardShape.strokeBorder(accent.opacity(0.25), lineWidth: 0.8)
        }
        .clipShape(cardShape)
        .padding(.bottom, 10)
    }
    
    // MARK: - List, Collection and completion time
    private var footer: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
            
            Text(listName)
                .lineLimit(1)
            
            if let collectionName {
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
                
                Text(collectionName)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            if let completedAt = task.dateCompleted {
                Text(completedAt.formatted(date: .omitted, time: .shortened))
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

//#Preview {
//    CompletedView()
//        .environment(Supabase())
//}
