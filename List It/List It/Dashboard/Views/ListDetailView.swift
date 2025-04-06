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
                
                VStack {
                    if let collections = list.collections, !collections.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(collections.indices, id: \.self) { index in
                                    let collectionBinding = Binding<Collection>(
                                        get: { list.collections![index] },
                                        set: { newCollection in
                                            var updatedCollections = list.collections!
                                            updatedCollections[index] = newCollection
                                            list.collections = updatedCollections
                                        }
                                    )
                                    
                                    CollectionView(collection: collectionBinding)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No collections yet")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .navigationTitle(list.listName)
                .navigationBarBackButtonHidden()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            backToDashboard = true
                        } label: {
                            NavigationBackButton()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showAddTaskView = true
                                print("Option 1 selected")
                            }) {
                                Label("Add Task", systemImage: "pencil")
                            }
                            Button(action: {
                                showAddcollectionView = true
                                print("Option 1 selected")
                            }) {
                                Label("Add Collection", systemImage: "list.bullet")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(colorScheme == .light ? .black : .white)
                        }
                    }
                }
                .background(
                    NavigationLink(destination: DashboardView(helper: helper, db: db), isActive: $backToDashboard) {
                        EmptyView()
                    }
                )
                .sheet(isPresented: $showAddcollectionView) {
                    AddCollectionView(helper: helper, list: $list)
                        .presentationDetents([.height(500)])
                        .presentationCornerRadius(25)
                        .interactiveDismissDisabled()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
    ListDetailView(list: $list, helper: Helper(), db: Supabase())
}
