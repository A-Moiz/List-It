//
//  ListDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import SwiftUI

struct ListDetailView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    let list: List
    @State var showAddTaskView: Bool = false
    @State var showAddNoteView: Bool = false
    @State var showAddCollectionView: Bool = false
    @State private var currentSort: SortOption = .oldest
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ListCollectionsView(list: list, currentSort: $currentSort)
            }
            .navigationTitle(list.listName)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(list: list)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
            .sheet(isPresented: $showAddNoteView) {
                AddNoteView(list: list)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
            .sheet(isPresented: $showAddCollectionView) {
                AddCollectionView(list: list)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
            .toolbar {
                if !list.isDefault {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showAddTaskView = true
                            }) {
                                Label("Add Task", systemImage: "pencil")
                            }
                            Button(action: {
                                showAddNoteView = true
                            }) {
                                Label("Add Note", systemImage: "note.text")
                            }
                            Button(action: {
                                showAddCollectionView = true
                            }) {
                                Label("Add Collection", systemImage: "folder")
                            }
                            Divider()
                            Menu {
                                Picker("Sort Collections", selection: $currentSort) {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            } label: {
                                Label("Sort by", systemImage: "arrow.up.arrow.down")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - All Lists in Collection
struct ListCollectionsView: View {
    @Environment(Supabase.self) var db
    let list: List
    @Binding var currentSort: SortOption
    
    var body: some View {
        Group {
            if list.isDefault {
                switch list.listName.lowercased() {
                case "completed":     CompletedView()
                case "not completed": NotCompletedView()
                case "today":         TodayView()
                case "tomorrow":      TomorrowView()
                case "overdue":       OverdueView()
                case "priority":      PriorityView()
                default:              EmptyView()
                }
            } else {
                AllCollectionsView(list: list, currentSort: $currentSort)
            }
        }
    }
}

// MARK: - Collection view
struct AllCollectionsView: View {
    @Environment(Supabase.self) var db
    let list: List
    @State var showUpdateCollection: Bool = false
    @State var showAlert: Bool = false
    @State var alertMode: AlertMode = .error
    @State var selectedCollectionToUpdate: Collection?
    @State var selectedCollectionToDelete: Collection?
    @Binding var currentSort: SortOption
    
    var filteredCollections: [Collection] {
        let base = db.collections.filter { $0.listID == list.id }
        
        switch currentSort {
        case .oldest:
            return base.sorted { $0.createdAt < $1.createdAt }
        case .newest:
            return base.sorted { $0.createdAt > $1.createdAt }
        case .alphabeticalAZ:
            return base.sorted { $0.collectionName.lowercased() < $1.collectionName.lowercased() }
        case .alphabeticalZA:
            return base.sorted { $0.collectionName.lowercased() > $1.collectionName.lowercased() }
        }
    }
    
    private var alertTitle: String {
        alertMode == .delete ? "Delete Collection?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Hold items for more options", systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if filteredCollections.isEmpty {
                ContentUnavailableView(
                    "No Collections",
                    systemImage: "folder.badge.plus",
                    description: Text("Add a collection to organize your tasks.")
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filteredCollections) { collection in
                        CollectionView(collection: collection)
                            .id("\(collection.id)-\(collection.collectionName)")
                            .padding(.vertical, 8)
                            .contextMenu {
                                if collection.collectionName.lowercased() != "general" {
                                    Button {
                                        selectedCollectionToUpdate = collection
                                        showUpdateCollection = true
                                    } label: {
                                        Label("Update Collection", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        selectedCollectionToDelete = collection
                                        alertMode = .delete
                                        showAlert = true
                                    } label: {
                                        Label("Delete Collection", systemImage: "trash")
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if alertMode == .delete {
                Button("Delete", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
        .sheet(item: $selectedCollectionToUpdate) { collection in
            UpdateCollectionView(collection: collection)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(25)
        }
    }
    
    // MARK: - Delete Collection
    func performDelete() {
        Task {
            guard let collectionToDelete = selectedCollectionToDelete else {
                alertMode = .error
                db.setError(title: "Error", message: "No Collection selected for deletion")
                showAlert = true
                return
            }
            let success = await db.deleteCollection(collection: collectionToDelete)
            
            if !success {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Collection view
struct CollectionView: View {
    let collection: Collection
    @State var isExpanded: Bool = false
    
    var body: some View {
        CollectionHeader(collection: collection, isExpanded: $isExpanded)
            .padding(.horizontal)
    }
}

// MARK: - Header view for Collections
struct CollectionHeader: View {
    let collection: Collection
    @Binding var isExpanded: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            CollectionDeatilView(collection: collection, isExpanded: $isExpanded)
            
            if isExpanded {
                CollectionTabView(collection: collection)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .clipped()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(collection.bgColor.opacity(0.5), lineWidth: 1.5)
        )
    }
}

// MARK: - Collections detail section
struct CollectionDeatilView: View {
    @Environment(Supabase.self) var db
    let collection: Collection
    @Binding var isExpanded: Bool
    @Environment(\.colorScheme) var colorScheme
    private var totalTasks: [ToDoTask] {
        db.tasks
            .filter { $0.collectionID == collection.id && !$0.isCompleted }
    }
    private var totalNotes: [Note] {
        db.notes
            .filter { $0.collectionID == collection.id }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Circle()
                        .fill(collection.bgColor)
                        .frame(width: 15, height: 15)
                    
                    Text(collection.collectionName)
                        .font(.system(size: 18, weight: .bold))
                }
                
                Text("\(totalTasks.count) Tasks · \(totalNotes.count) Notes")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .padding(10)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .background(
                        Circle()
                            .fill(.gray.opacity(0.5)))
            }
        }
    }
}

// MARK: - Tab view for Collections
struct CollectionTabView: View {
    @State private var selectedTab: Int = 0
    let collection: Collection
    
    var body: some View {
        VStack(spacing: 15) {
            Picker("Selection", selection: $selectedTab) {
                Text("Tasks").tag(0)
                Text("Notes").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            TabView(selection: $selectedTab) {
                TaskListView(collection: collection)
                    .tag(0)
                
                NoteListView(collection: collection)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 300)
        }
        .padding(.vertical)
    }
}

// MARK: - All Tasks view
struct TaskListView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    let collection: Collection
    @State var selectedTask: ToDoTask?
    @State private var taskToDelete: ToDoTask?
    var filteredTasks: [ToDoTask] {
        db.tasks
            .filter { task in
                task.collectionID == collection.id && !task.isCompleted && !task.isDeleted
            }
            .sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned && !$1.isPinned
                }
                return $0.createdAt > $1.createdAt
            }
    }
    @State var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "pencil.and.list.clipboard",
                    description: Text("Try adding a Task to this Collection.")
                )
            } else {
                TaskKeyView()
                ScrollView {
                    ForEach(filteredTasks, id: \.id) { task in
                        TaskView(task: task)
                            .onTapGesture {
                                selectedTask = task
                            }
                            .contextMenu { taskContextMenu(task) }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
        .alert(db.alertTitle, isPresented: $showAlert) {
            switch alertMode {
            case .delete:
                Button("Delete", role: .destructive) {
                    Task {
                        guard let task = taskToDelete else { return }
                        
                        let success = await db.deleteTask(task: task)
                        if !success {
                            alertMode = .error
                            showAlert = true
                        } else {
                            taskToDelete = nil
                        }
                    }
                }
                Button("Cancel", role: .cancel) { taskToDelete = nil }
                
            case .error:
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(db.alertMessage)
        }
    }
    
    // MARK: - Extracted Context Menu
    @ViewBuilder
    private func taskContextMenu(_ task: ToDoTask) -> some View {
        let availableCollections = db.collections.filter { $0.listID == task.listID }
        
        // Move
        Menu {
            ForEach(availableCollections) { collection in
                Button {
                    Task {
                        let success = await db.moveTask(task: task, newCollectionID: collection.id)
                        
                        if !success {
                            showAlert = true
                        }
                    }
                } label: {
                    HStack {
                        Text(collection.collectionName)
                        if task.collectionID == collection.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(task.collectionID == collection.id)
            }
        } label: {
            Label("Move Task", systemImage: "folder.badge.plus")
        }
        
        // Pin
        Button {
            Task {
                let success = await db.updatePinForTask(task: task, isPinned: task.isPinned ? false : true)
                if !success {
                    db.setError(title: "Pin Error", message: "Error updating Task Pin")
                    showAlert = true
                }
            }
        } label: {
            Label(task.isPinned ? "Unpin Task" : "Pin Task", systemImage: task.isPinned ? "pin.fill" : "pin")
        }
        
        // Delete
        Button {
            taskToDelete = task
            alertMode = .delete
            db.setError(title: "Delete Task", message: "Are you sure you want to delete this Task?")
            showAlert = true
        } label: {
            Label("Delete Task", systemImage: "trash")
        }
    }
}

// MARK: - Task Key
struct TaskKeyView: View {
    var body: some View {
        HStack {
            Spacer()
            // Overdue
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
            Text("Overdue")
                .font(.caption)
            
            // Pinned
            Circle()
                .fill(.orange)
                .frame(width: 10, height: 10)
            Text("Flagged")
                .font(.caption)
            
            // Pinned
            Circle()
                .fill(.yellow)
                .frame(width: 10, height: 10)
            Text("Pinned")
                .font(.caption)
            
            // Default
            Circle()
                .fill(.cyan)
                .frame(width: 10, height: 10)
            Text("Normal")
                .font(.caption)
            
            Spacer()
        }
    }
}

// MARK: - Task view
struct TaskView: View {
    let task: ToDoTask
    @Environment(Supabase.self) var db
    private var barColor: Color {
        if let dueDate = task.dueDate, dueDate < Date() {
            return .red
        }
        
        if task.isPinned {
            return task.dueDate == nil ? .yellow : .orange
        }
        
        return .cyan
    }
    private var collection: Collection? {
        let collectionID = task.collectionID
        return db.collections.first(where: { $0.id == collectionID })
    }
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(barColor)
                .frame(width: 7, height: 70)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.text)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    if let dueDate = task.dueDate {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        
                        Text("Due: \(db.formattedDate(dueDate))")
                            .font(.system(size: 10))
                            .foregroundStyle(dueDate < Date() ? .red : .secondary)
                            .bold()
                    } else {
                        Image(systemName: "calendar")
                            .font(.caption)
                        
                        Text("Created: \(db.formattedDate(task.createdAt))")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(collection?.bgColor.opacity(0.1) ?? .clear)
        )
        .padding(.horizontal)
    }
}

// MARK: - All Notes view
struct NoteListView: View {
    @Environment(Supabase.self) var db
    let collection: Collection
    @State var selectedNote: Note?
    @State private var noteToDelete: Note?
    
    var filteredNotes: [Note] {
        db.notes.filter { $0.collectionID == collection.id }
            .sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned && !$1.isPinned
                }
                return $0.createdAt > $1.createdAt
            }
    }
    @State var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    
    var body: some View {
        VStack(alignment: .leading) {
            if filteredNotes.isEmpty {
                ContentUnavailableView(
                    "No Notes",
                    systemImage: "note.text",
                    description: Text("Try adding a Note to this Collection.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 16) {
                        ForEach(filteredNotes) { note in
                            NoteView(note: note)
                                .onTapGesture { selectedNote = note }
                                .contextMenu { noteContextMenu(note) }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailView(note: note)
        }
        .alert(db.alertTitle, isPresented: $showAlert) {
            switch alertMode {
            case .delete:
                Button("Delete", role: .destructive) {
                    Task {
                        guard let note = noteToDelete else { return }
                        
                        let success = await db.deleteNote(note: note)
                        if !success {
                            alertMode = .error
                            showAlert = true
                        } else {
                            noteToDelete = nil
                        }
                    }
                }
                Button("Cancel", role: .cancel) { noteToDelete = nil }
                
            case .error:
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(db.alertMessage)
        }
    }
    
    // MARK: - Extracted Context Menu
    @ViewBuilder
    private func noteContextMenu(_ note: Note) -> some View {
        let availableCollections = db.collections.filter { $0.listID == note.listID }
        
        Menu {
            ForEach(availableCollections) { targetCollection in
                Button {
                    Task {
                        let success = await db.moveNote(note: note, newCollectionID: targetCollection.id)
                        if !success { showAlert = true }
                    }
                } label: {
                    HStack {
                        Text(targetCollection.collectionName)
                        if note.collectionID == targetCollection.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(note.collectionID == targetCollection.id)
            }
        } label: {
            Label("Move Note", systemImage: "folder.badge.plus")
        }
        
        // Pin
        Button {
            Task {
                let success = await db.updatePinForNote(note: note, isPinned: note.isPinned ? false : true)
                if !success {
                    showAlert = true
                }
            }
        } label: {
            Label(note.isPinned ? "Unpin Note" : "Pin Note", systemImage: note.isPinned ? "pin.fill" : "pin")
        }
        
        // Delete
        Button {
            noteToDelete = note
            alertMode = .delete
            db.setError(title: "Delete Note", message: "Are you sure you want to delete this Note?")
            showAlert = true
        } label: {
            Label("Delete Note", systemImage: "trash")
        }
    }
}

// MARK: - Note view
struct NoteView: View {
    let note: Note
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if note.isPinned {
                HStack {
                    Spacer()
                    Image(systemName: "pin.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            } else {
                Color.clear.frame(height: 10)
            }
            
            Text(note.title)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if let description = note.description, !description.isEmpty {
                Text(description)
                    .font(.caption2)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 110, height: 110)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(note.bgColor.opacity(colorScheme == .dark ? 0.3 : 0.6))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(note.bgColor.opacity(0.5), lineWidth: 1)
        }
    }
}

#Preview {
    //        @Previewable @State var list: List = List(id: "", createdAt: Date(), listIcon: "", listName: "Test List", isDefault: false, bgColorHex: "", userId: "", isPinned: false)
    //        ListDetailView(list: list)
    //            .environment(Supabase())
    
    //    @Previewable @State var collection: Collection = Collection(id: "", createdAt: Date(), collectionName: "Test Collection", bgColorHex: "#FF3B30", listID: "", userID: "")
    //
    //    CollectionView(collection: collection)
    //        .environment(Supabase())
    
    //    @Previewable @State var task: ToDoTask = ToDoTask(id: "", createdAt: Date(), text: "The Price of Confession", description: "Episode 1", isCompleted: false, isDeleted: false, isPinned: false, userID: "", collectionID: "", listID: "")
    
    //    @Previewable @State var task: ToDoTask = ToDoTask(id: "", createdAt: Date(), text: "Mouse", description: "Episode 3", dueDate: Date(), isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false, userID: "", collectionID: "", listID: "")
    //
    //    TaskView(task: task)
    //        .environment(Supabase())
    
    @Previewable @State var notes: Note = Note(id: "", createdAt: Date(), title: "Anime", description: "- Code Geas S1 (8/10)", isDeleted: false, bgColorHex: "#FF3B30", isPinned: true, collectionID: "", userID: "", listID: "")
    
    NoteView(note: notes)
        .environment(Supabase())
}
