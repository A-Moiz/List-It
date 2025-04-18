//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 06/04/2025.
//

import SwiftUI

//struct CollectionView: View {
//    @Binding var collection: Collection
//    @State private var isExpanded: Bool = false
//    @State private var selectedTab: Tab = .task
//    @State private var tabProgress: CGFloat = 0
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    private var scrollPositionBinding: Binding<Tab?> {
//        Binding<Tab?>(
//            get: { selectedTab },
//            set: { newValue in
//                if let newTab = newValue {
//                    selectedTab = newTab
//                }
//            }
//        )
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text(collection.collectionName)
//                    .font(.headline)
//                
//                Spacer()
//                
//                Button {
//                    withAnimation {
//                        isExpanded.toggle()
//                    }
//                } label: {
//                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding()
//            .background(Color(hex: collection.bgColorHex))
//            .cornerRadius(10)
//            .shadow(radius: 2)
//            
//            if isExpanded {
//                TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
//                    .padding(.vertical)
//                
//                GeometryReader { geometry in
//                    let size = geometry.size
//                    ScrollView(.horizontal) {
//                        LazyHStack(spacing: 0) {
//                            ScrollView(.vertical) {
//                                VStack(alignment: .leading, spacing: 8) {
//                                    if collection.tasks.isEmpty {
//                                        Text("No tasks in this collection.")
//                                            .foregroundColor(.gray)
//                                            .padding(.top, 8)
//                                    } else {
//                                        ForEach($collection.tasks, id: \.id) { $task in
//                                            TaskView(task: $task)
//                                                .padding(.horizontal)
//                                                .containerRelativeFrame(.horizontal)
//                                        }
//                                    }
//                                }
//                                .padding(.top, 8)
//                                .frame(width: size.width)
//                            }
//                            .id(Tab.task)
//                            
//                            ScrollView(.vertical) {
//                                VStack {
//                                    if collection.notes.isEmpty {
//                                        Text("No notes in this collection.")
//                                            .foregroundColor(.gray)
//                                            .padding(.top, 8)
//                                            .frame(maxWidth: .infinity, alignment: .center)
//                                    } else {
//                                        LazyVGrid(columns: [
//                                            GridItem(.flexible(), spacing: 16),
//                                            GridItem(.flexible(), spacing: 16)
//                                        ], spacing: 16) {
//                                            ForEach($collection.notes, id: \.id) { $note in
//                                                NoteView(note: $note, collection: $collection, helper: helper, db: db)
//                                                    .aspectRatio(contentMode: .fill)
//                                                    .frame(minHeight: 120)
//                                                    .cornerRadius(8)
//                                            }
//                                        }
//                                    }
//                                }
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
//                                .frame(width: size.width)
//                            }
//                            .id(Tab.note)
//                        }
//                        .scrollTargetLayout()
//                        .offsetX { value in
//                            let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
//                            tabProgress = max(min(progress, 1), 0)
//                        }
//                    }
//                    .scrollPosition(id: scrollPositionBinding)
//                    .scrollIndicators(.hidden)
//                    .scrollTargetBehavior(.paging)
//                }
//                .frame(minHeight: 100, maxHeight: .infinity)
//                .frame(height: UIScreen.main.bounds.height * 0.3)
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//}

//struct CollectionView: View {
//    @Binding var collection: Collection
//    @State private var isExpanded: Bool = false
//    @State private var selectedTab: Tab = .task
//    @State private var tabProgress: CGFloat = 0
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @State var isDeleteView: Bool
//
//    private var scrollPositionBinding: Binding<Tab?> {
//        Binding<Tab?>(
//            get: { selectedTab },
//            set: { newValue in
//                if let newTab = newValue {
//                    selectedTab = newTab
//                }
//            }
//        )
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header card
//            HStack {
//                Text(collection.collectionName)
//                    .font(.title3.bold())
//                    .foregroundColor(.white)
//
//                Spacer()
//                
//                if !isDeleteView {
//                    Button {
//                        withAnimation(.spring()) {
//                            isExpanded.toggle()
//                        }
//                    } label: {
//                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                            .foregroundColor(.white)
//                            .imageScale(.medium)
//                            .padding(8)
//                            .background(.ultraThinMaterial)
//                            .clipShape(Circle())
//                    }
//                }
//            }
//            .padding()
//            .background(Color(hex: collection.bgColorHex))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//            .padding(.horizontal)
//
//            if isExpanded {
//                VStack(spacing: 12) {
//                    TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
//                        .padding(.top)
//
//                    GeometryReader { geometry in
//                        let size = geometry.size
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            LazyHStack(spacing: 0) {
//                                // Tasks
//                                ScrollView(.vertical, showsIndicators: false) {
//                                    VStack(alignment: .leading, spacing: 12) {
//                                        if collection.tasks.isEmpty {
//                                            Text("No tasks in this collection.")
//                                                .foregroundColor(.gray)
//                                                .frame(maxWidth: .infinity, alignment: .center)
//                                                .padding(.top, 16)
//                                        } else {
//                                            let sortedTasks = collection.tasks.sorted {
//                                                if $0.isPinned != $1.isPinned {
//                                                    return $0.isPinned && !$1.isPinned
//                                                } else {
//                                                    return $0.dateCreated > $1.dateCreated
//                                                }
//                                            }
//
//                                            ForEach(sortedTasks, id: \.id) { task in
//                                                if let binding = $collection.tasks.first(where: { $0.id == task.id }) {
//                                                    TaskView(task: binding, collection: $collection, db: db, helper: helper)
//                                                        .padding(.horizontal)
//                                                        .transition(.slide)
//                                                }
//                                            }
//                                        }
//                                    }
//                                    .frame(width: size.width)
//                                }
//                                .id(Tab.task)
//
//                                // Notes
//                                ScrollView(.vertical, showsIndicators: false) {
//                                    VStack(spacing: 12) {
//                                        if collection.notes.isEmpty {
//                                            Text("No notes in this collection.")
//                                                .foregroundColor(.gray)
//                                                .frame(maxWidth: .infinity, alignment: .center)
//                                                .padding(.top, 16)
//                                        } else {
//                                            LazyVGrid(columns: [
//                                                GridItem(.flexible(), spacing: 16),
//                                                GridItem(.flexible(), spacing: 16)
//                                            ], spacing: 16) {
//                                                let sortedNotes = collection.notes.sorted {
//                                                    if $0.isPinned != $1.isPinned {
//                                                        return $0.isPinned && !$1.isPinned
//                                                    } else {
//                                                        return $0.dateCreated > $1.dateCreated
//                                                    }
//                                                }
//
//                                                ForEach(sortedNotes, id: \.id) { note in
//                                                    if let binding = $collection.notes.first(where: { $0.id == note.id }) {
//                                                        NoteView(note: binding, collection: $collection, helper: helper, db: db)
//                                                            .aspectRatio(contentMode: .fill)
//                                                            .frame(minHeight: 120)
//                                                            .background(.thinMaterial)
//                                                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
//                                                    }
//                                                }
//                                            }
//                                            .padding(.horizontal, 16)
//                                        }
//                                    }
//                                    .frame(width: size.width)
//                                    .padding(.top, 8)
//                                }
//                                .id(Tab.note)
//                            }
//                            .scrollTargetLayout()
//                            .offsetX { value in
//                                let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
//                                tabProgress = max(min(progress, 1), 0)
//                            }
//                        }
//                        .scrollTargetBehavior(.paging)
//                        .scrollPosition(id: scrollPositionBinding)
//                    }
//                    .frame(height: UIScreen.main.bounds.height * 0.35)
//                }
//                .transition(.opacity)
//                .padding(.top, 8)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .animation(.easeInOut(duration: 0.3), value: isExpanded)
//    }
//}

//struct CollectionView: View {
//    @Binding var collection: Collection
//    @Binding var list: List
//    @State private var isExpanded: Bool = false
//    @State private var selectedTab: Tab = .task
//    @State private var tabProgress: CGFloat = 0
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @State var isDeleteView: Bool
//
//    private var scrollPositionBinding: Binding<Tab?> {
//        Binding<Tab?>(
//            get: { selectedTab },
//            set: { newValue in
//                if let newTab = newValue {
//                    selectedTab = newTab
//                }
//            }
//        )
//    }
//
//    private var sortedTasks: [Task] {
//        collection.tasks.sorted {
//            if $0.isPinned != $1.isPinned {
//                return $0.isPinned && !$1.isPinned
//            } else {
//                return $0.dateCreated > $1.dateCreated
//            }
//        }
//    }
//
//    private var sortedNotes: [Note] {
//        collection.notes.sorted {
//            if $0.isPinned != $1.isPinned {
//                return $0.isPinned && !$1.isPinned
//            } else {
//                return $0.dateCreated > $1.dateCreated
//            }
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header card
//            HStack {
//                Text(collection.collectionName)
//                    .font(.title3.bold())
//                    .foregroundColor(.white)
//
//                Spacer()
//
//                if !isDeleteView {
//                    Button {
//                        withAnimation(.spring()) {
//                            isExpanded.toggle()
//                        }
//                    } label: {
//                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                            .foregroundColor(.white)
//                            .imageScale(.medium)
//                            .padding(8)
//                            .background(.ultraThinMaterial)
//                            .clipShape(Circle())
//                    }
//                }
//            }
//            .padding()
//            .background(Color(hex: collection.bgColorHex))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//            .padding(.horizontal)
//
//            if isExpanded {
//                VStack(spacing: 12) {
//                    TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
//                        .padding(.top)
//
//                    GeometryReader { geometry in
//                        let size = geometry.size
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            LazyHStack(spacing: 0) {
//                                taskListView(size: size)
//                                noteListView(size: size)
//                            }
//                            .scrollTargetLayout()
//                            .offsetX { value in
//                                let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
//                                tabProgress = max(min(progress, 1), 0)
//                            }
//                        }
//                        .scrollTargetBehavior(.paging)
//                        .scrollPosition(id: scrollPositionBinding)
//                    }
//                    .frame(height: UIScreen.main.bounds.height * 0.35)
//                }
//                .transition(.opacity)
//                .padding(.top, 8)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .animation(.easeInOut(duration: 0.3), value: isExpanded)
//    }
//
//    private func taskListView(size: CGSize) -> some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 12) {
//                if sortedTasks.isEmpty {
//                    Text("No tasks in this collection.")
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.top, 16)
//                } else {
//                    ForEach(sortedTasks, id: \.id) { task in
//                        if let index = collection.tasks.firstIndex(where: { $0.id == task.id }) {
//                            TaskView(task: $collection.tasks[index], collection: $collection, list: $list, db: db, helper: helper)
//                                .padding(.horizontal)
//                                .transition(.slide)
//                        }
//                    }
//                }
//            }
//            .frame(width: size.width)
//        }
//        .id(Tab.task)
//    }
//
//    private func noteListView(size: CGSize) -> some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            VStack(spacing: 12) {
//                if collection.notes.isEmpty {
//                    Text("No notes in this collection.")
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.top, 16)
//                } else {
//                    LazyVGrid(columns: [
//                        GridItem(.flexible(), spacing: 16),
//                        GridItem(.flexible(), spacing: 16)
//                    ], spacing: 16) {
//                        ForEach(sortedNotes, id: \.id) { note in
//                            if let binding = $collection.notes.first(where: { $0.id == note.id }) {
//                                NoteView(note: binding, collection: $collection, helper: helper, db: db)
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(minHeight: 120)
//                                    .background(.thinMaterial)
//                                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                }
//            }
//            .frame(width: size.width)
//            .padding(.top, 8)
//        }
//        .id(Tab.note)
//    }
//}

struct CollectionView: View {
    @Binding var collection: Collection
    @Binding var list: List
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Tab = .task
    @State private var tabProgress: CGFloat = 0
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State var isDeleteView: Bool
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    private var scrollPositionBinding: Binding<Tab?> {
        Binding<Tab?>(
            get: { selectedTab },
            set: { newValue in
                if let newTab = newValue {
                    selectedTab = newTab
                }
            }
        )
    }
    
    private var sortedTasks: [Task] {
        collection.tasks.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            } else {
                return $0.dateCreated > $1.dateCreated
            }
        }
    }
    
    private var sortedNotes: [Note] {
        collection.notes.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            } else {
                return $0.dateCreated > $1.dateCreated
            }
        }
    }
    
    private var collectionColor: Color {
        Color(hex: collection.bgColorHex)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header card with improved design
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(collectionColor)
                                .frame(width: 14, height: 14)
                            
                            Text(collection.collectionName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("\(sortedTasks.count) tasks · \(sortedNotes.count) notes")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.leading, 24)
                    }
                    
                    Spacer()
                    
                    if !isDeleteView {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary.opacity(0.7))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ?
                                              Color(UIColor.systemGray5) :
                                              Color(UIColor.systemGray6))
                                )
                        }
                    }
                }
                
                if isExpanded {
                    HStack(spacing: 10) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            TabButton(tab: tab, selectedTab: $selectedTab, namespace: animation)
                        }
                    }
                    .padding(.top, 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ?
                          Color(UIColor.systemGray6) :
                          Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(collectionColor.opacity(0.5), lineWidth: 1.5)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Content area
            if isExpanded {
                VStack(spacing: 0) {
                    // Tab View content
                    TabView(selection: $selectedTab) {
                        taskListView()
                            .tag(Tab.task)
                        
                        noteListView()
                            .tag(Tab.note)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: selectedTab) { newValue in
                        withAnimation {
                            selectedTab = newValue
                        }
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    private func taskListView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                if sortedTasks.isEmpty {
                    emptyStateView(
                        icon: "checklist",
                        message: "No tasks in this collection",
                        subMessage: "Add a task to get started"
                    )
                } else {
                    ForEach(sortedTasks, id: \.id) { task in
                        if let index = collection.tasks.firstIndex(where: { $0.id == task.id }) {
                            TaskView(
                                task: $collection.tasks[index],
                                collection: $collection,
                                list: $list,
                                db: db,
                                helper: helper
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, 8)
        }
    }
    
    private func noteListView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sortedNotes.isEmpty {
                emptyStateView(
                    icon: "note.text",
                    message: "No notes in this collection",
                    subMessage: "Add a note to get started"
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(sortedNotes, id: \.id) { note in
                        if let binding = $collection.notes.first(where: { $0.id == note.id }) {
                            NoteView(note: binding, collection: $collection, helper: helper, db: db)
                                .aspectRatio(contentMode: .fill)
                                .frame(minHeight: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(colorScheme == .dark ?
                                              Color(UIColor.systemGray6) :
                                              Color.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(note.isPinned ? Color.yellow : Color.clear, lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
    
    private func emptyStateView(icon: String, message: String, subMessage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(collectionColor.opacity(0.6))
                .padding(.bottom, 8)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Text(subMessage)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// Supporting Views
struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    var namespace: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: tab == .task ? "checklist" : "note.text")
                        .font(.system(size: 13))
                    
                    Text(tab == .task ? "Tasks" : "Notes")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(selectedTab == tab ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemBlue))
                                .matchedGeometryEffect(id: "TAB", in: namespace)
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    let sampleTasks = [
        Task(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
    ]
    
    let sampleNotes = [
        Note(id: UUID().uuidString, title: "Watering", description: "Don't forget to water the plants.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false)
    ]
    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: sampleTasks, notes: sampleNotes)
    @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), type: .regular, collections: [], isPinned: false)
    CollectionView(collection: $collection, list: $list, helper: Helper(), db: Supabase(), isDeleteView: false)
}
