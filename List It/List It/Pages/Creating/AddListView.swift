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
            ScrollView{
                Image(systemName: "checklist.checked")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                InputField(
                    icon: "checklist",
                    text: $listName,
                    placeholder: "What's your new List called?"
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
            }
            .navigationTitle("Add List")
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
                        createList()
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
        
        let listID = UUID().uuidString
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
