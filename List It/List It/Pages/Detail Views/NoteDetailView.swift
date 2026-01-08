//
//  NoteDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    var note: Note
    
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedHex: String = ""
    @State private var isPinned: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMode: AlertMode = .error
    
    private var collection: Collection? {
        db.collections.first(where: { $0.id == note.collectionID })
    }
    
    private var alertTitle: String {
        alertMode == .delete ? "Delete Note?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Note Title") {
                    TextField("Title", text: $editedTitle)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Description") {
                    TextEditor(text: $editedDescription)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Appearance") {
                    ColorInputView(selectedColorHex: $editedHex)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
                
                Section("Actions") {
                    Button {
                        isPinned.toggle()
                    } label: {
                        Label(isPinned ? "Unpin Note" : "Pin Note", systemImage: isPinned ? "pin.fill" : "pin")
                            .symbolEffect(.bounce, value: isPinned)
                    }
                    .tint(.orange)
                    
                    Button(role: .destructive) {
                        alertMode = .delete
                        showAlert = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                    }
                }
                .listRowBackground(Color(.systemBackground).opacity(0.8))
            }
            .navigationTitle("Note Details")
            .toolbarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color(hex: editedHex).opacity(0.3))
            .onAppear {
                editedTitle = note.title
                editedDescription = note.description ?? ""
                editedHex = note.bgColorHex
                isPinned = note.isPinned
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .fontWeight(.bold)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                if alertMode == .delete {
                    Button("Delete", role: .destructive) { performDelete() }
                    Button("Cancel", role: .cancel) { }
                } else {
                    Button("OK", role: .cancel) { }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Save changes
    func saveChanges() {
        guard !editedTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            db.setError(title: "Required", message: "Your note must have a title.")
            alertMode = .error
            showAlert = true
            return
        }
        
        Task {
            let success = await db.updateNote(
                note: note,
                title: editedTitle,
                description: editedDescription,
                hex: editedHex,
                isPinned: isPinned
            )
            
            if success {
                await MainActor.run { dismiss() }
            } else {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
    
    // MARK: - Delete note
    func performDelete() {
        Task {
            let success = await db.deleteNote(note: note)
            if success {
                await MainActor.run { dismiss() }
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
    @Previewable @State var notes: Note = Note(id: "", createdAt: Date(), title: "Anime", description: "- Code Geas S1 (8/10)", isDeleted: false, bgColorHex: "#FF3B30", isPinned: true, collectionID: "", userID: "", listID: "")
    NoteDetailView(note: notes)
        .environment(Supabase())
}
