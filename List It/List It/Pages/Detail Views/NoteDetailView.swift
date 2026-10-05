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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Note title", text: $editedTitle)
                        .font(.title3.weight(.semibold))
                    
                    Divider()
                    
                    descriptionField
                    
                    Divider()
                    
                    ColorInputView(selectedColorHex: $editedHex)
                    
                    Divider()
                    
                    actionsRow
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Note Details")
            .toolbarTitleDisplayMode(.inline)
            .background(Color(hex: editedHex).opacity(0.08))
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
    
    // MARK: - Description
    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            if editedDescription.isEmpty {
                Text("Add a description")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }

            Text(editedDescription.isEmpty ? " " : editedDescription)
                .padding(.top, 8)
                .padding(.leading, 5)
                .opacity(0)
            
            TextEditor(text: $editedDescription)
                .scrollContentBackground(.hidden)
        }
        .frame(minHeight: 100, maxHeight: 500)
    }
    
    // MARK: - Actions
    private var actionsRow: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation {
                    isPinned.toggle()
                }
            } label: {
                Label(isPinned ? "Unpin" : "Pin", systemImage: isPinned ? "pin.fill" : "pin")
                    .symbolEffect(.bounce, value: isPinned)
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            
            Button {
                alertMode = .delete
                showAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            Spacer()
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

//#Preview {
//    NoteDetailView()
//        .environment(Supabase())
//}
