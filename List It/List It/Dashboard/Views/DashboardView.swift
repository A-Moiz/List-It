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
                        Text("Your Collections")
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
                                ListView(list: list)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
            .sheet(isPresented: $showAddListView) {
                AddListView(helper: helper, lists: $db.lists)
                .presentationDetents([.height(500)])
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    DashboardView(helper: Helper(), db: Supabase())
}
