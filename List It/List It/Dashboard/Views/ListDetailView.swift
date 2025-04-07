//
//  CollectionDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

struct ListDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var backToDashboard: Bool = false
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State private var showAddTaskView: Bool = false
    @State private var showAddcollectionView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                listContentView
                    .navigationTitle(list.listName)
                    .navigationBarBackButtonHidden()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .toolbar {
                        leadingToolbarItems
                        trailingToolbarItems
                    }
                    .background(navigationLink)
                    .sheet(isPresented: $showAddcollectionView) {
                        AddCollectionView(helper: helper, list: $list)
                            .presentationDetents([.height(500)])
                            .presentationCornerRadius(25)
                            .interactiveDismissDisabled()
                    }
                    .sheet(isPresented: $showAddTaskView) {
                        AddTaskView(list: $list, helper: helper)
                            .presentationDetents([.height(500)])
                            .presentationCornerRadius(25)
                            .interactiveDismissDisabled()
                    }
            }
        }
    }
    
    private var listContentView: some View {
        VStack {
            if !list.collections.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        collectionsForEachView(collections: list.collections)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No collections yet")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    private func collectionsForEachView(collections: [Collection]) -> some View {
        ForEach($list.collections, id: \.id) { $collection in
            CollectionView(collection: $collection)
        }
    }
    
    private var leadingToolbarItems: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                backToDashboard = true
            } label: {
                NavigationBackButton()
            }
        }
    }
    
    private var trailingToolbarItems: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: {
                    showAddTaskView = true
                }) {
                    Label("Add Task", systemImage: "pencil")
                }
                Button(action: {
                    showAddcollectionView = true
                }) {
                    Label("Add Collection", systemImage: "list.bullet")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
    }
    
    private var navigationLink: some View {
        NavigationLink(destination: DashboardView(helper: helper, db: db), isActive: $backToDashboard) {
            EmptyView()
        }
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, collections: [])
    ListDetailView(list: $list, helper: Helper(), db: Supabase())
}
