//
//  AddListView.swift
//  List It
//
//  Created by Abdul Moiz on 04/01/2026.
//

import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Supabase.self) var db
    @State var listName: String = ""
    @State var selectedColorHex: String = ""
    @State var showAlert: Bool = false
    var lists: [List]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 80))
                            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                        
                        Text("Create a new List to stay organised.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)
                
                Section("List Name") {
                    InputField(
                        icon: "pencil.line",
                        text: $listName,
                        placeholder: "e.g. Personal, Work, Fitness"
                    )
                }
                .listRowBackground(Color(.systemBackground).opacity(0.7))
                
                Section("Appearance") {
                    ColorInputView(selectedColorHex: $selectedColorHex)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.7))
            }
            .navigationTitle("Add List")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createList() }
                        .fontWeight(.bold)
                        .disabled(listName.isEmpty)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(db.alertTitle), message: Text(db.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Check if fields are empty
    func isFieldsEmpty() -> Bool {
        return listName.isEmpty || selectedColorHex.isEmpty
    }
    
    // MARK: - Check if List name exists
    func isValidName() -> Bool {
        return !lists.contains(where: {
            $0.listName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == listName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        })
    }
    
    // MARK: - Create the list
    func createList() {
        guard !isFieldsEmpty() else {
            db.setError(title: "Error", message: "Please enter a name and choose a color.")
            showAlert = true
            return
        }
        
        guard isValidName() else {
            db.setError(title: "Error", message: "A list with this name already exists.")
            showAlert = true
            return
        }
        
        let listID = UUID().uuidString.lowercased()
        let newList = List(id: listID, createdAt: Date(), listIcon: "checklist", listName: listName, isDefault: false, bgColorHex: selectedColorHex, userId: "", isPinned: false)
        
        let generalCollection = Collection(id: UUID().uuidString, createdAt: Date(), collectionName: "General", bgColorHex: selectedColorHex, listID: listID, userID: "")

        Task {
            let saved = await db.saveList(newList: newList, generalCollection: generalCollection)
            
            guard saved else {
                showAlert = true
                return
            }
            
            await MainActor.run {
                db.lists.append(newList)
                db.collections.append(generalCollection)
                
                dismiss()
            }
        }
    }
}

#Preview {
    @Previewable @State var lists = [
        List(id: UUID().uuidString, createdAt: Date(), listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
    ]
    AddListView(lists: lists)
        .environment(Supabase())
}
