//
//  DashboardView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct Collection {
    var icon: String
    var name: String
    var contentCount: Int
    var fillColor: Color
}

struct DashboardView: View {
    @State var searchText: String = ""
    @State var showAddCollectionView: Bool = false
    @State var collections = [
        Collection(icon: "scribble", name: "Today", contentCount: 10, fillColor: .orange),
        Collection(icon: "", name: "Favorites", contentCount: 5, fillColor: .blue),
        Collection(icon: "lasso", name: "Work", contentCount: 8, fillColor: .green),
        Collection(icon: "", name: "Personal", contentCount: 12, fillColor: .purple),
        Collection(icon: "", name: "Study", contentCount: 7, fillColor: .red)
    ]
    
    var filteredCollections: [Collection] {
        if searchText.isEmpty {
            return collections
        } else {
            return collections.filter { collection in
                collection.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        .padding()
                    
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
                            ForEach(filteredCollections, id: \.name) { collection in
                                CollectionView(collectionIcon: collection.icon, fillColor: collection.fillColor,
                                               collectionName: collection.name,
                                               contentCount: collection.contentCount)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
            .sheet(isPresented: $showAddCollectionView) {
                AddCollectionView(collections: $collections)
                .presentationDetents([.height(500)])
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    DashboardView()
}
