//
//  DeleteCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 09/04/2025.
//

import SwiftUI

struct DeleteCollectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State private var selectedCollections: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach($list.collections, id: \.id) { $collection in
                                HStack(spacing: 10) {
                                    Button(action: {
                                        toggleSelection(for: collection.id)
                                    }) {
                                        Image(systemName: selectedCollections.contains(collection.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(.accentColor)
                                    }

                                    CollectionView(collection: $collection, helper: helper, db: db, isDeleteView: true)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }

                    if !selectedCollections.isEmpty {
                        Button(role: .destructive) {
                            helper.showAlertWithMessage("Are you sure you want to delete the selected collections?")
                        } label: {
                            Text("Delete Selected (\(selectedCollections.count))")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut, value: selectedCollections)
            }
            .navigationTitle("Delete Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .alert("Delete Collections?", isPresented: $helper.showAlert) {
                Button("Cancel", role: .cancel) {
                    helper.showAlert = false
                }
                Button("Delete", role: .destructive) {
                    deleteSelectedCollections()
                    dismiss()
                }
            } message: {
                Text(helper.alertMessage)
            }
        }
    }

    private func toggleSelection(for id: String) {
        if selectedCollections.contains(id) {
            selectedCollections.remove(id)
        } else {
            selectedCollections.insert(id)
        }
    }

    private func deleteSelectedCollections() {
        list.collections.removeAll { collection in
            selectedCollections.contains(collection.id)
        }
    }
}

#Preview {
    let sampleCollections = [
        Collection(id: UUID().uuidString, collectionName: "Science", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: []),
        Collection(id: UUID().uuidString, collectionName: "English", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: []),
        Collection(id: UUID().uuidString, collectionName: "Maths", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: [])
    ]
    @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, collections: sampleCollections)
    DeleteCollectionView(list: $list, helper: Helper(), db: Supabase())
}
