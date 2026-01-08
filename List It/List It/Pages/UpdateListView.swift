//
//  UpdateListView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct UpdateListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Supabase.self) var db
    var list: List
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
            Form {
                Section("List Name") {
                    TextField("List Name", text: $editedName)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Appearance") {
                    ColorInputView(selectedColorHex: $editedHex)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
            }
            .navigationTitle("Update List")
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
                        saveChanges()
                    } label: {
                        Text("Update")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(list.bgColor.opacity(0.3))
            .onAppear {
                editedName = list.listName
                editedHex = list.bgColorHex
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
            db.setError(title: "Required", message: "Your List must have a name.")
            alertMode = .error
            showAlert = true
            return
        }
        
        Task {
            let success = await db.updateList(list: list, name: editedName, hex: editedHex)
            
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
    @Previewable @State var list: List = List(id: "", createdAt: Date(), listIcon: "checklist", listName: "Test List", isDefault: false, bgColorHex: "#007AFF", userId: "", isPinned: false)
    UpdateListView(list: list)
        .environment(Supabase())
}
