//
//  CollectionDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

struct ListDetailView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @State var backToListView: Bool = false
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State private var showAddTaskView: Bool = false
    @State private var showAddNoteView: Bool = false
    @State private var showAddcollectionView: Bool = false
    @State private var showDeletecollectionView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                listContentView
                    .transition(.opacity.combined(with: .scale))
                    .navigationTitle(list.listName)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .toolbar {
                        if !list.isDefault {
                            trailingToolbarItems
                        }
                    }
                    .sheet(isPresented: $showAddcollectionView) {
                        AddCollectionView(helper: helper, db: db, list: $list)
                            .presentationDetents([.height(600)])
                            .presentationCornerRadius(15)
                            .interactiveDismissDisabled()
                    }
                    .sheet(isPresented: $showAddTaskView) {
                        AddTaskView(list: $list, helper: helper, db: db)
                            .presentationDetents([.height(600)])
                            .presentationCornerRadius(15)
                            .interactiveDismissDisabled()
                    }
                    .sheet(isPresented: $showAddNoteView) {
                        AddNoteView(list: $list, helper: helper, db: db)
                            .presentationDetents([.height(600)])
                            .presentationCornerRadius(15)
                            .interactiveDismissDisabled()
                    }
                    .alert(isPresented: $helper.showAlert) {
                        Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .onAppear {
                        db.fetchUserCollections { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching collections: \(error)")
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: - Custom List views
    private var listContentView: some View {
        VStack {
            if list.listName.lowercased() == "completed" {
                CompletedListView(list: $list, helper: helper, db: db)
            } else if list.listName.lowercased() == "not completed" {
                NotCompletedListView(list: $list, helper: helper, db: db)
            } else if list.listName.lowercased() == "today" {
                TodayListView(list: $list, helper: helper, db: db)
            } else if list.listName.lowercased() == "tomorrow" {
                TomorrowListView(list: $list, helper: helper, db: db)
            } else if list.listName.lowercased() == "overdue" {
                OverdueListView(list: $list, helper: helper, db: db)
            } else if list.listName.lowercased() == "priority" {
                PriorityListView(list: $list, helper: helper, db: db)
            } else {
                if db.collections.filter({ $0.listID == list.id }).isEmpty {
                    Text("No collections in this List")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        // MARK: - Helper Text
                        HStack {
                            Text("💡 Hold collections, tasks & notes for more options")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                collectionsForEachView()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Collection views
    private func collectionsForEachView() -> some View {
        ForEach(db.collections.indices.filter { db.collections[$0].listID == list.id }, id: \.self) { index in
            CollectionView(
                collection: $db.collections[index],
                list: $list,
                helper: helper,
                db: db
            )
        }
    }
    
    // MARK: - Tookbar items
    private var trailingToolbarItems: ToolbarItem<(), some View> {
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
                    showAddcollectionView = true
                }) {
                    Label("Add Collection", systemImage: "list.bullet")
                }
                Button(action: {
                    showDeletecollectionView = true
                }) {
                    Label("Delete Collection(s)", systemImage: "x.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
    }
}

//#Preview {
//    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    ListDetailView(list: $list, helper: Helper(), db: Supabase())
//}
