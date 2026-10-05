//
//  UpdateCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct UpdateCollectionView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    var collection: Collection
    @State var editedName: String = ""
    @State var editedHex: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    private var alertTitle: String {
        alertMode == .delete ? "Delete Note?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Collection name", text: $editedName)
                        .font(.title3.weight(.semibold))
                    
                    Divider()
                    
                    ColorInputView(selectedColorHex: $editedHex)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Update Collection")
            .navigationBarTitleDisplayMode(.inline)
            .background(collection.bgColor.opacity(0.08))
            .onAppear {
                editedName = collection.collectionName
                editedHex = collection.bgColorHex
            }
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
                        saveChanges()
                    } label: {
                        Text("Update")
                    }
                    .fontWeight(.bold)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                if alertMode == .error {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Save changes
    func saveChanges() {
        guard !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            db.setError(title: "Required", message: "Your Collection must have a name.")
            alertMode = .error
            showAlert = true
            return
        }
        
        Task {
            let success = await db.updateCollection(collection: collection, name: editedName, hex: editedHex)
            
            if success {
                await MainActor.run {
                    dismiss()
                }
            } else {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var collection: Collection = Collection(id: "", createdAt: Date(), collectionName: "", bgColorHex: "", listID: "", userID: "")
    UpdateCollectionView(collection: collection)
        .environment(Supabase())
}
