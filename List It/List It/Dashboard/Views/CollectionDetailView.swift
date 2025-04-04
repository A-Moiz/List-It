//
//  CollectionDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

struct CollectionDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var backToDashboard: Bool = false
    @Binding var collection: Collection
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    Text(collection.collectionName)
                        .font(.title)
                        .bold()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            backToDashboard = true
                        } label: {
                            NavigationBackButton()
                        }
                    }
                }
                .background(
                    NavigationLink(destination: DashboardView(helper: helper, db: db)) {
                        EmptyView()
                    }
                        .hidden()
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var collection = Collection(id: NSUUID().uuidString, collectionName: "Today", bgColor: .orange, dateCreated: Date(), isDefault: true)
    CollectionDetailView(collection: $collection, helper: Helper(), db: Supabase())
}
