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

struct CollectionView: View {
    @Binding var collection: Collection
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Tab = .task
    @State private var tabProgress: CGFloat = 0
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State var isDeleteView: Bool

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

    var body: some View {
        VStack(spacing: 0) {
            // Header card
            HStack {
                Text(collection.collectionName)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Spacer()
                
                if !isDeleteView {
                    Button {
                        withAnimation(.spring()) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .background(Color(hex: collection.bgColorHex))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.horizontal)

            if isExpanded {
                VStack(spacing: 12) {
                    TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
                        .padding(.top)

                    GeometryReader { geometry in
                        let size = geometry.size

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                // Tasks
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        if collection.tasks.isEmpty {
                                            Text("No tasks in this collection.")
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(.top, 16)
                                        } else {
                                            ForEach($collection.tasks, id: \.id) { $task in
                                                TaskView(task: $task)
                                                    .padding(.horizontal)
                                                    .transition(.slide)
                                            }
                                        }
                                    }
                                    .frame(width: size.width)
                                }
                                .id(Tab.task)

                                // Notes
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 12) {
                                        if collection.notes.isEmpty {
                                            Text("No notes in this collection.")
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(.top, 16)
                                        } else {
                                            LazyVGrid(columns: [
                                                GridItem(.flexible(), spacing: 16),
                                                GridItem(.flexible(), spacing: 16)
                                            ], spacing: 16) {
                                                ForEach($collection.notes, id: \.id) { $note in
                                                    NoteView(note: $note, collection: $collection, helper: helper, db: db)
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(minHeight: 120)
                                                        .background(.thinMaterial)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                    .frame(width: size.width)
                                    .padding(.top, 8)
                                }
                                .id(Tab.note)
                            }
                            .scrollTargetLayout()
                            .offsetX { value in
                                let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
                                tabProgress = max(min(progress, 1), 0)
                            }
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: scrollPositionBinding)
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.35)
                }
                .transition(.opacity)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
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
    CollectionView(collection: $collection, helper: Helper(), db: Supabase(), isDeleteView: false)
}
