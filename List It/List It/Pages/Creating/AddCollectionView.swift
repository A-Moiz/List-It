//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import SwiftUI

struct AddCollectionView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    @State var collectionName: String = ""
    @State var selectedColorHex: String = ""
    @State var showAlert: Bool = false
    var list: List
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    
                    Divider()
                    
                    InputField(
                        icon: "folder",
                        text: $collectionName,
                        placeholder: "e.g. Groceries, High Priority"
                    )
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ColorInputView(selectedColorHex: $selectedColorHex)
                        
                        Text("If no color is selected, this will inherit the **\(list.listName)** list colour.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Add Collection")
            .navigationBarTitleDisplayMode(.inline)
            .background(list.bgColor.opacity(0.08))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createCollection() }
                        .fontWeight(.bold)
                        .disabled(collectionName.isEmpty)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.fill.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(.blue)
            
            Text("Group your tasks & notes into collections.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Check if name is empty
    func isFieldEmpty() -> Bool {
        return collectionName.isEmpty
    }
    
    // MARK: - Check if Collection name exists
    func isValidName(for listId: String) -> Bool {
        let newName = collectionName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return !db.collections.contains { collection in
            collection.listID == list.id &&
            collection.collectionName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() == newName
        }
    }
    
    // MARK: - Create the Collection
    func createCollection() {
        guard !isFieldEmpty() else {
            db.setError(title: "Error", message: "Please enter a name for your new Collection")
            showAlert = true
            return
        }
        
        guard isValidName(for: list.id) else {
            db.setError(title: "Error", message: "A Collection with this name already exists within this List.")
            showAlert = true
            return
        }
        
        let listID = list.id
        let collectionID = UUID().uuidString.lowercased()
        let finalColorHex = selectedColorHex.isEmpty
        ? list.bgColorHex
        : selectedColorHex
        let newCollection = Collection(id: collectionID, createdAt: Date(), collectionName: collectionName, bgColorHex: finalColorHex, listID: listID, userID: "")
        
        Task {
            let saved = await db.saveCollection(newCollection: newCollection)
            
            guard saved else {
                showAlert = true
                return
            }
            
            let fetched = await db.fetchUserCollections()
            
            if fetched {
                await MainActor.run {
                    dismiss()
                }
            } else {
                await MainActor.run {
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var collections: Collection = Collection(id: "", createdAt: Date(), collectionName: "", bgColorHex: "", listID: "", userID: "")
    
    @Previewable @State var list: List = List(id: UUID().uuidString, createdAt: Date(), listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
    
    AddCollectionView(list: list)
        .environment(Supabase())
}
