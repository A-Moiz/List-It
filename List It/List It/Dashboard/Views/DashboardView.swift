//
//  DashboardView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct DashboardView: View {
    @State var searchText: String = ""
    @State var showAddCollectionView: Bool = false
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    var filteredCollections: [Collection] {
        if searchText.isEmpty {
            return db.collections
        } else {
            return db.collections.filter { collection in
                collection.collectionName.lowercased().contains(searchText.lowercased())
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
                        
                        Text("Explore Your Collections")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding()
                    
                    CustomSearchBar(text: $searchText, prompt: "Search Collection...")
                    
                    Divider()
                    
                    HStack {
                        Text("Your Collections")
                            .bold()
                        Spacer()
                        Button {
                            print("Add collection")
                            showAddCollectionView = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .font(.title2)
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(filteredCollections, id: \.id) { collection in
                                CollectionView(collection: collection)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
            .sheet(isPresented: $showAddCollectionView) {
                AddCollectionView(helper: helper, collections: $db.collections)
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
