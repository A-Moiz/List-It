//
//  AddNoteView.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var title: String = ""
    @State var description: String = ""
    @State var selectedColorHex: String = ""
    @State private var isPinned: Bool = false
    @State private var selectedCollectionName: String? = nil
    @ObservedObject var helper: Helper
    @Binding var list: List
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        CustomTextField(icon: "pencil", placeholder: "Note title", text: $title, isPassword: false, showPassword: false)
                        
                        VStack {
                            Text("Add your note here:")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                                .padding(.top)
                            
                            TransparentTextEditor(text: $description)
                                .frame(minHeight: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.4), lineWidth: 1)
                                )
                                .padding(8)
                        }
                        
                        ColorSelectionView(colorHexes: AppConstants.listColorHexes, selectedHex: $selectedColorHex)
                        
                        Text("Selected Color: \(selectedColorHex.isEmpty ? "None" : selectedColorHex)")
                            .font(.headline)
                            .foregroundColor(Color(hex: selectedColorHex.isEmpty ? "#A9A9A9" : selectedColorHex))
                        
                        Toggle(isOn: $isPinned) {
                            Label("Pin this note", systemImage: "pin.fill")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.bottom)
                        
                        Menu {
                            ForEach(list.collections, id: \.id) { collection in
                                Button(action: {
                                    selectedCollectionName = collection.collectionName
                                }) {
                                    HStack {
                                        Text(collection.collectionName)
                                        if selectedCollectionName == collection.collectionName {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCollectionName ?? "Select Collection")
                                    .foregroundColor(selectedCollectionName == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                        }
                        
                        Divider()
                            .padding()
                        
                        Button {
                            createNote()
                        } label: {
                            ButtonView(text: "Create Note", icon: "arrow.right")
                                .padding(.horizontal, 50)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    func createNote() {
        guard isFieldsFilled() else {
            helper.showAlertWithMessage("All fields must be filled in.")
            return
        }
        
        let newNote = Note(id: UUID().uuidString, title: title, description: description, dateCreated: Date(), isDeleted: false, bgColorHex: selectedColorHex, isPinned: isPinned)
        
        addToCollection(newNote: newNote)
        dismiss()
    }
    
    func addToCollection(newNote: Note) {
        if let name = selectedCollectionName, let index = list.collections.firstIndex(where: {$0.collectionName == name}) {
            if list.collections[index].notes == nil {
                list.collections[index].notes = []
            }
            list.collections[index].notes.append(newNote)
        } else {
            if let generalIndex = list.collections.firstIndex(where: {$0.collectionName == "General"}) {
                if list.collections[generalIndex].notes == nil {
                    list.collections[generalIndex].notes = []
                }
                list.collections[generalIndex].notes.append(newNote)
            } else {
                let generalCollection = Collection(id: UUID().uuidString, collectionName: "General", bgColorHex: "#87CEEB", dateCreated: Date(), notes: [newNote])
                list.collections.append(generalCollection)
            }
        }
    }
    
    func isFieldsFilled() -> Bool {
        return !title.isEmpty && !description.isEmpty && !selectedColorHex.isEmpty
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), collections: [], isPinned: false)
    AddNoteView(helper: Helper(), list: $list)
}
