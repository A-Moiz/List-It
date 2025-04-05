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
    @State private var selectedTab: Tab = .task
    @State private var tabProgress: CGFloat = 0
    @State private var showAddTaskView: Bool = false
    @State private var showAddcollectionView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
                        .padding(.top)
                    
                    TabContentView(selectedTab: $selectedTab, tabProgress: $tabProgress)
                }
                .navigationTitle(list.listName)
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
                    NavigationLink(destination: DashboardView(helper: helper, db: db)) {
                        EmptyView()
                    }
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
    ListDetailView(list: $list, helper: Helper(), db: Supabase())
}
