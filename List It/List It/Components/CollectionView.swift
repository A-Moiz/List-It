//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 06/04/2025.
//

import SwiftUI

struct CollectionView: View {
    // MARK: - Properties
    @Binding var collection: Collection
    @Binding var list: List
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Tab = .task
    @State private var tabProgress: CGFloat = 0
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    // MARK: - Computed properties
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
    private var sortedTasks: [ToDoTask] {
        db.userTasks
            .filter { $0.collectionID == collection.id && !$0.isCompleted }
            .sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned && !$1.isPinned
                } else {
                    return $0.createdAt > $1.createdAt
                }
            }
    }
    private var sortedNotes: [Note] {
        db.userNotes
            .filter { $0.collectionID == collection.id }
            .sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned && !$1.isPinned
                } else {
                    return $0.createdAt > $1.createdAt
                }
            }
    }
    private var collectionColor: Color {
        Color(hex: collection.bgColorHex)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    // MARK: - Collection details
                    VStack(alignment: .leading, spacing: 4) {
                        // MARK: - Collection name
                        HStack(spacing: 10) {
                            Circle()
                                .fill(collectionColor)
                                .frame(width: 14, height: 14)
                            
                            Text(collection.collectionName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.primary)
                        }
                        
                        Text("\(sortedTasks.count) Tasks · \(sortedNotes.count) Notes")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .padding(.leading, 24)
                    }
                    
                    Spacer()
                    
                    // MARK: - Expand/Collapse arrow
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.primary.opacity(0.7))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ?
                                          Color(UIColor.systemGray5) :
                                          Color(UIColor.systemGray6))
                            )
                    }
                }
                
                // MARK: - Expanded view
                if isExpanded {
                    HStack(spacing: 10) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            TabButton(tab: tab, selectedTab: $selectedTab, namespace: animation, collectionColor: collectionColor)
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
            
            // MARK: - Expanded view
            /// Display tasks and notes if expanded
            if isExpanded {
                VStack(spacing: 0) {
                    TabView(selection: $selectedTab) {
                        TaskListView(collection: $collection, list: $list, db: db, helper: helper, collectionColor: collectionColor)
                            .tag(Tab.task)
                        
                        NoteListView(collection: $collection, list: $list, db: db, helper: helper, collectionColor: collectionColor)
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
        .contextMenu {
            if collection.collectionName.lowercased() != "general" {
                Button(role: .destructive) {
                    withAnimation {
                        db.deleteCollection(collection: collection) { success, error in
                            if !success {
                                helper.showAlertWithMessage("Error deleting Collection: \(error)")
                            } else {
                                db.fetchUserCollections { success, errorMessage in
                                    if !success, let error = errorMessage {
                                        helper.showAlertWithMessage("Error fetching Collections: \(error)")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Label("Delete Collection", systemImage: "trash")
                }
            } else {
                Label("Cannot delete General collection", systemImage: "lock")
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

//#Preview {
//    let sampleTasks = [
//        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
//        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
//        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
//        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
//    ]
//    
//    let sampleNotes = [
//        Note(id: UUID().uuidString, title: "Watering", description: "Don't forget to water the plants.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false)
//    ]
//    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: sampleTasks, notes: sampleNotes)
//    @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    CollectionView(collection: $collection, list: $list, helper: Helper(), db: Supabase(), isDeleteView: false)
//}
