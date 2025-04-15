//
//  DashboardView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct DashboardView: View {
    @State var searchText: String = ""
    @State var showAddListView: Bool = false
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    var filteredLists: [List] {
        if searchText.isEmpty {
            return db.lists
        } else {
            return db.lists.filter { list in
                list.listName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome Back 👋")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Explore Your Lists")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding()
                    
                    CustomSearchBar(text: $searchText, prompt: "Search List...")
                    
                    Divider()
                    
                    HStack {
                        Text("Your Lists")
                            .bold()
                        Spacer()
                        Button {
                            print("Add collection")
                            showAddListView = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .font(.title2)
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(filteredLists, id: \.id) { list in
                                listView(for: list)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showAddListView) {
                AddListView(helper: helper, lists: $db.lists)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    @ViewBuilder
    func listView(for list: List) -> some View {
        guard let index = db.lists.firstIndex(where: { $0.id == list.id }) else {
            return AnyView(EmptyView())
        }

        let listBinding = Binding<List>(
            get: { db.lists[index] },
            set: { db.lists[index] = $0 }
        )

        switch list.type {
        case .regular:
            return AnyView(ListView(list: listBinding, helper: helper, db: db))
        case .completed:
            return AnyView(CompletedListView(list: listBinding, helper: helper, db: db))
        case .notCompleted:
            return AnyView(NotCompletedListView())
        }
    }
}

#Preview {
    DashboardView(helper: Helper(), db: Supabase())
}
