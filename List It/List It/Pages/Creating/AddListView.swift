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
    @Environment(\.colorScheme) var colorScheme
    @State var listName: String = ""
    @State var selectedColorHex: String = ""
    @State var showAlert: Bool = false
    var lists: [List]
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            header
                            
                            Divider()
                            
                            InputField(
                                icon: "pencil.line",
                                text: $listName,
                                placeholder: "e.g. Personal, Work, Fitness"
                            )
                            
                            Divider()
                            
                            ColorInputView(selectedColorHex: $selectedColorHex)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer(minLength: 0)
                        Spacer(minLength: 0)
                    }
                    .padding(20)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Add List")
            .navigationBarTitleDisplayMode(.inline)
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
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

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "checklist.checked")
                .font(.system(size: 36))
                .foregroundStyle(.orange)
            
            Text("Create a new List to stay organised.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
