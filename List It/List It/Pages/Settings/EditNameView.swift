//
//  EditNameView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct EditNameView: View {
    @Environment(Supabase.self) var db
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var editedName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    
    private var alertTitle: String {
        alertMode == .delete ? "" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "" : db.alertMessage
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("User Name") {
                    TextField("User Name", text: $editedName)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                editedName = db.currentUser?.name ?? ""
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
                        updateName()
                    } label: {
                        Text("Update")
                    }
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
    
    // MARK: - Update name
    func updateName() {
        guard !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            db.setError(title: "Required", message: "User name cannot be empty.")
            alertMode = .error
            showAlert = true
            return
        }
        
        Task {
            let success = await db.updateName(name: editedName)
            
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
    EditNameView()
        .environment(Supabase())
}
