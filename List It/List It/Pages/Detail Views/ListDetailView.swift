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
    @State var showTaskInfoView: Bool = false
    @State private var currentSort: SortOption = .oldest
    @State private var searchText: String = ""
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    
    var body: some View {
        NavigationStack {
            ScrollView {
                AllCollectionsView(list: list, currentSort: $currentSort, searchText: searchText)
            }
            .navigationTitle(list.listName)
            .navigationBarTitleDisplayMode(.inline)
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(list: list)
                    .presentationDetents([.medium, .large])
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showAddNoteView) {
                AddNoteView(list: list)
                    .presentationDetents([.medium, .large])
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showAddCollectionView) {
                AddCollectionView(list: list)
                    .presentationDetents([.medium, .large])
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showTaskInfoView) {
                TaskInfoView()
                    .presentationDetents([.medium])
            }
            .toolbar {
                if !list.isDefault {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showTaskInfoView = true
                        }) {
                            Label("Task Info", systemImage: "i.circle")
                        }
                    }
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
            .searchable(text: $searchText, prompt: "Search tasks & notes")
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
    let searchText: String
    
    // Filter by List ID and Search Content
    var filteredCollections: [Collection] {
        let base = db.collections.filter { collection in
            // Show collections for current list
            guard collection.listID == list.id else { return false }
            
            // If search is empty, show all collections in this list
            if searchText.isEmpty { return true }
            
            // Check if any Task inside this collection matches the search
            let hasMatchingTasks = db.tasks.contains { task in
                task.collectionID == collection.id &&
                task.text.localizedCaseInsensitiveContains(searchText) &&
                !task.isCompleted
            }
            
            // Check if any Note inside this collection matches the search
            let hasMatchingNotes = db.notes.contains { note in
                note.collectionID == collection.id &&
                note.title.localizedCaseInsensitiveContains(searchText)
            }
            
            return hasMatchingTasks || hasMatchingNotes
        }
        
        // Sort the filtered results
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
                        CollectionView(collection: collection, searchText: searchText)
                            .id("\(collection.id)-\(collection.collectionName)")
                            .padding(.vertical, 4)
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
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
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
    let searchText: String
    private var shouldExpand: Bool {
        !searchText.isEmpty || isExpanded
    }
    
    var body: some View {
        CollectionHeader(
            collection: collection,
            isExpanded: Binding(
                get: { shouldExpand },
                set: { isExpanded = $0 }
            ),
            searchText: searchText
        )
        .padding(.horizontal)
    }
}

// MARK: - Header view for Collections
struct CollectionHeader: View {
    let collection: Collection
    @Binding var isExpanded: Bool
    @Environment(\.colorScheme) private var colorScheme
    let searchText: String
    private let cornerRadius: CGFloat = 17
    private var isDark: Bool { colorScheme == .dark }
    private var headerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CollectionDeatilView(
                collection: collection,
                isExpanded: $isExpanded
            )
            .padding(.vertical, 14)
            .padding(.leading, 12)
            .background {
                ZStack {
                    headerShape.fill(
                        isDark ? Color(.secondarySystemGroupedBackground) : Color.white
                    )
                    
                    GeometryReader { geometry in
                        DiagonalSliceShape(skewOffset: isExpanded ? 0 : 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        collection.bgColor.opacity(isDark ? 0.40 : 0.20),
                                        collection.bgColor.opacity(isDark ? 0.20 : 0.10)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: isExpanded ? geometry.size.width : geometry.size.width * 0.30)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isExpanded.toggle()
            }
            .zIndex(2)
            
            if isExpanded {
                VStack(spacing: 0) {
                    CollectionTabView(
                        collection: collection,
                        searchText: searchText
                    )
                    .padding(.leading, 12)
                    .padding(.top, 14)
                    .padding(.bottom, 12)
                }
                .background(isDark ? Color.black.opacity(0.12) : Color(.systemGroupedBackground).opacity(0.3))
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .zIndex(1)
            }
        }
        .overlay {
            headerShape.strokeBorder(
                collection.bgColor.opacity(isDark ? 0.25 : 0.16),
                lineWidth: 0.8
            )
        }
        .clipShape(headerShape)
        .animation(.snappy(duration: 0.32, extraBounce: 0.04), value: isExpanded)
        .rotation3DEffect(
            .degrees(isExpanded ? 0 : -6),
            axis: (x: 1.0, y: -0.4, z: 0.0),
            anchor: .center,
            anchorZ: 0.0,
            perspective: 0.35
        )
        .offset(x: isExpanded ? 0 : 6, y: isExpanded ? 0 : -4)
        .zIndex(3)
    }
}

// MARK: - Diagonal Shape
struct DiagonalSliceShape: Shape {
    var skewOffset: CGFloat
    var animatableData: CGFloat {
        get { skewOffset }
        set { skewOffset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: max(rect.minX, rect.maxX - skewOffset), y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.closeSubpath()
        return path
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
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(collection.collectionName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(totalTasks.count) Tasks · \(totalNotes.count) Notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(collection.bgColor))
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .padding(.trailing)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab view for Collections
struct CollectionTabView: View {
    @State private var selectedTab: Int = 0
    let collection: Collection
    let searchText: String
    
    private let tabs = ["Tasks", "Notes"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            tabSwitcher
            
            TabView(selection: $selectedTab) {
                TaskListView(collection: collection, searchText: searchText)
                    .tag(0)
                
                NoteListView(collection: collection, searchText: searchText)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 300)
        }
    }
    
    // MARK: Tab switcher
    private var tabSwitcher: some View {
        HStack(spacing: 20) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundStyle(selectedTab == index ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? collection.bgColor : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
    }
}

// MARK: - All Tasks view
struct TaskListView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    let collection: Collection
    @State var selectedTask: ToDoTask?
    @State private var taskToDelete: ToDoTask?
    let searchText: String
    var filteredTasks: [ToDoTask] {
        db.tasks
            .filter { task in
                let matchesCollection = task.collectionID == collection.id
                let isActive = !task.isCompleted && !task.isDeleted
                
                let matchesSearch = searchText.isEmpty ||
                task.text.localizedCaseInsensitiveContains(searchText)
                
                return matchesCollection && isActive && matchesSearch
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
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredTasks, id: \.id) { task in
                            TaskView(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                }
                                .contextMenu { taskContextMenu(task) }
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .presentationDetents([.medium, .large])
                .interactiveDismissDisabled()
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

// MARK: - Task view
struct TaskView: View {
    let task: ToDoTask
    @Environment(Supabase.self) var db
    private var barColor: Color {
        if let schedule = task.schedule, schedule < Date() {
            return .red
        }
        
        if task.isPinned {
            return task.schedule == nil ? .yellow : .orange
        }
        
        return .cyan
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(barColor)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.text)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    
                    if let schedule = task.schedule {
                        Text("Scheduled: \(db.formattedDate(schedule))")
                            .font(.caption2)
                            .fontWeight(schedule < Date() ? .semibold : .regular)
                            .foregroundStyle(schedule < Date() ? .red : .secondary)
                    } else {
                        Text("Created: \(db.formattedDate(task.createdAt))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

// MARK: - All Notes view
struct NoteListView: View {
    @Environment(Supabase.self) var db
    let collection: Collection
    @State var selectedNote: Note?
    @State private var noteToDelete: Note?
    let searchText: String
    var filteredNotes: [Note] {
        db.notes
            .filter { note in
                let matchesCollection = note.collectionID == collection.id
                let isActive = !note.isDeleted
                
                let matchesSearch = searchText.isEmpty || note.title.localizedCaseInsensitiveContains(searchText)
                
                return matchesCollection && isActive && matchesSearch
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
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
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
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredNotes) { note in
                            NoteView(note: note)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedNote = note }
                                .contextMenu { noteContextMenu(note) }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailView(note: note)
                .presentationDetents([.medium, .large])
                .interactiveDismissDisabled()
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
    @Environment(\.colorScheme) private var colorScheme
    private let foldSize: CGFloat = 16
    private let cornerRadius: CGFloat = 8
    private var isDark: Bool {
        colorScheme == .dark
    }
    private var noteShape: FoldedNoteShape {
        FoldedNoteShape(cornerRadius: cornerRadius, foldSize: foldSize)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.trailing, note.isPinned ? 12 : 0)
            
            if let description = note.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: 10))
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background {
            ZStack {
                noteShape
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(isDark ? 0.35 : 0.12),
                        radius: 3,
                        x: 0,
                        y: 2
                    )
                
                noteShape.fill(
                    LinearGradient(
                        colors: [
                            note.bgColor.opacity(isDark ? 0.50 : 0.40),
                            note.bgColor.opacity(isDark ? 0.28 : 0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        .overlay {
            noteShape.stroke(note.bgColor.opacity(0.35), lineWidth: 0.8)
        }
        .overlay(alignment: .topTrailing) {
            if note.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            foldedCorner
        }
    }
    
    // MARK: - Folded corner
    private var foldedCorner: some View {
        ZStack {
            FoldFlapShape().fill(Color(.systemBackground))
            FoldFlapShape().fill(note.bgColor.opacity(isDark ? 0.55 : 0.45))
        }
        .frame(width: foldSize, height: foldSize)
        .shadow(color: .black.opacity(0.2), radius: 1.5, x: -1, y: -1)
    }
}

// MARK: - Note outline with the bottom-right corner cut off
struct FoldedNoteShape: Shape {
    var cornerRadius: CGFloat
    var foldSize: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = cornerRadius
        let f = foldSize
        
        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - f))
        path.addLine(to: CGPoint(x: rect.maxX - f, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - The flap that is folded over the cut corner
struct FoldFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

//#Preview {
//    NoteView()
//        .environment(Supabase())
//}
