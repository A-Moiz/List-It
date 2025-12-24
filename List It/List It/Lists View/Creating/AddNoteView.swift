//
//  AddNoteView.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import SwiftUI

struct AddNoteView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @State var title: String = ""
    @State var description: String = ""
    @State var isPinned: Bool = false
    @State var selectedCollectionName: String?
    @State var selectedColorHex: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // MARK: - Header Section
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "note.text.badge.plus")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Create Note")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Capture your thoughts and ideas")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Note Content Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.orange)
                                Text("Note Content")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            // MARK: - Note Title
                            NoteTextField(
                                icon: "textformat.abc",
                                placeholder: "Enter note title...",
                                text: $title
                            )
                            
                            // MARK: - Note Description
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "pencil.and.outline")
                                        .foregroundColor(.orange)
                                        .frame(width: 20)
                                    Text("Write your note")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                
                                NoteTextEditor(text: $description)
                                    .frame(minHeight: 120)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
                        )
                        
                        // MARK: - Customization Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .foregroundColor(.pink)
                                Text("Customize")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            // MARK: - Color Selection
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.pink)
                                        .frame(width: 20)
                                    Text("Background Color")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                
                                ColorSelectionView(
                                    colorHexes: AppConstants.listColorHexes,
                                    selectedHex: $selectedColorHex
                                )
                                
                                // MARK: - Color Preview
                                VStack {
                                    if !selectedColorHex.isEmpty {
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: selectedColorHex))
                                                .frame(width: 32, height: 24)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(.white, lineWidth: 2)
                                                        .shadow(color: .black.opacity(0.1), radius: 2)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Selected Color")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(selectedColorHex.uppercased())
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color(hex: selectedColorHex))
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                        )
                                        .transition(.scale.combined(with: .opacity))
                                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedColorHex)
                                    }
                                    
                                    Text("If no color is selected, the note will use its collection’s color by default.")
                                        .font(.caption)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
                        )
                        
                        // MARK: - Options Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.blue)
                                Text("Options")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            // MARK: - Pin Toggle
                            ToggleRow(
                                icon: "pin.fill",
                                title: "Pin Note",
                                subtitle: "Keep at the top of your notes",
                                isOn: $isPinned,
                                accentColor: .orange
                            )
                            
                            // MARK: - Collection Selector
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "folder")
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    Text("Collection")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                
                                Menu {
                                    ForEach(db.collections.filter { $0.listID == list.id }, id: \.id) { collection in
                                        Button(action: {
                                            selectedCollectionName = collection.collectionName
                                        }) {
                                            HStack {
                                                Image(systemName: "folder")
                                                Text(collection.collectionName)
                                                if selectedCollectionName == collection.collectionName {
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "folder")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Collection")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(selectedCollectionName ?? "General")
                                                .font(.body)
                                                .fontWeight(.medium)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
                        )
                        
                        // MARK: - Create Button
                        VStack {
                            Button(action: {
                                createNote()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("Create Note")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .pink],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .orange.opacity(0.4), radius: 12, x: 0, y: 6)
                                )
                            }
                            .buttonStyle(PressedButtonStyle())
                            .disabled(title.isEmpty)
                            .opacity(title.isEmpty ? 0.6 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: title.isEmpty || selectedColorHex.isEmpty)
                            
                            Text("Title is required before creating a Note.")
                                .font(.caption)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.body)
                    }
                }
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Creating Note component
    func createNote() {
        let matchedCollection = db.collections.first {
            $0.collectionName == (selectedCollectionName ?? "General") && $0.listID == list.id
        }
        // Determine background color
        let resolvedColorHex: String = {
            if !selectedColorHex.isEmpty {
                return selectedColorHex
            }
            
            if let collectionColor = matchedCollection?.bgColorHex, !collectionColor.isEmpty {
                return collectionColor
            }
            
            return list.bgColorHex
        }()
        let createdDate = db.dateAndTime(Date())
        let newNote = Note(id: UUID().uuidString, createdAt: createdDate ?? Date(), title: title, description: description, isDeleted: false, bgColorHex: resolvedColorHex, isPinned: isPinned, collectionID: matchedCollection?.id ?? "", userID: "", listID: list.id)
        
        db.saveNote(newNote: newNote) { success, errorMessage in
            if !success, let error = errorMessage {
                helper.showAlertWithMessage("Error creating note: \(error)")
            } else {
                db.fetchUserNotes { success, errorMessage in
                    if !success, let error = errorMessage {
                        helper.showAlertWithMessage("Error fetching new Note: \(error)")
                    }
                }
                dismiss()
            }
        }
    }
}

//
//#Preview {
//    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    AddNoteView(helper: Helper(), list: $list)
//}
