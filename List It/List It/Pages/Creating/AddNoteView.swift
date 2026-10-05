//
//  AddNoteView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Supabase.self) var db
    var list: List
    @State private var noteTitle: String = ""
    @State private var noteDescription: String = ""
    @State private var selectedCollectionID: String?
    @State private var isPinned: Bool = false
    @State private var selectedColorHex: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Note title", text: $noteTitle)
                            .font(.title3.weight(.semibold))
                        
                        TextField("Description (optional)", text: $noteDescription, axis: .vertical)
                            .lineLimit(3...5)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ColorInputView(selectedColorHex: $selectedColorHex)
                        
                        Text("If no color is selected, the Note will use its Collection's colour by default.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 14) {
                        TaskOrganisationRow(list: list, selectedCollectionID: $selectedCollectionID)
                        
                        Toggle(isOn: $isPinned) {
                            Label("Pin Note", systemImage: isPinned ? "pin.fill" : "pin")
                        }
                        .tint(.orange)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createNote() }
                        .fontWeight(.bold)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Spacer()
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(.yellow)
            Spacer()
        }
    }
    
    // MARK: - Create Note
    func createNote() {
        guard !noteTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            db.setError(title: "Required", message: "Please enter a title for your note.")
            showAlert = true
            return
        }

        let targetCollection = db.collections.first(where: {
            $0.id == selectedCollectionID
        }) ?? db.collections.first(where: {
            $0.listID == list.id && $0.collectionName == "General"
        })

        let finalHex = selectedColorHex.isEmpty ? (targetCollection?.bgColorHex ?? "#808080") : selectedColorHex
        
        let newNote = Note(
            id: UUID().uuidString.lowercased(),
            createdAt: Date(),
            title: noteTitle,
            description: noteDescription.isEmpty ? nil : noteDescription,
            isDeleted: false,
            bgColorHex: finalHex,
            isPinned: isPinned,
            collectionID: targetCollection?.id ?? "",
            userID: "",
            listID: list.id
        )
        
        Task {
            let success = await db.saveNote(newNote: newNote)
            if success {
                await MainActor.run {
                    db.notes.append(newNote)
                    dismiss()
                }
            } else {
                await MainActor.run { showAlert = true }
            }
        }
    }
}

#Preview {
    @Previewable @State var lists = List(id: UUID().uuidString, createdAt: Date(), listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
    AddNoteView(list: lists)
        .environment(Supabase())
}
