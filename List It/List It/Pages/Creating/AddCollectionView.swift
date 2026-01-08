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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Image(systemName: "folder")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                InputField(
                    icon: "checklist",
                    text: $collectionName,
                    placeholder: "What's your new Collection called?"
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding()
                
                ColorInputView(selectedColorHex: $selectedColorHex)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding()
                
                Text("If no color is selected, the Collection will use its List’s colour by default.")
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Add Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createCollection()
                    } label: {
                        Text("Create")
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
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
        let collectionID = UUID().uuidString
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
                dismiss()
            } else {
                showAlert = true
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
