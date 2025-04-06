//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct AddCollectionView: View {
    @State var collectionName: String = ""
    @State var selectedColorHex: String = ""
    @ObservedObject var helper: Helper
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var list: List
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    CustomTextField(icon: "checklist", placeholder: "List Name", text: $collectionName, isPassword: false, showPassword: false)
                    
                    ColorSelectionView(colorHexes: AppConstants.listColorHexes, selectedHex: $selectedColorHex)
                    
                    Text("Selected Color: \(selectedColorHex.isEmpty ? "None" : selectedColorHex)")
                        .font(.headline)
                        .foregroundColor(Color(hex: selectedColorHex.isEmpty ? "#A9A9A9" : selectedColorHex))
                    
                    Divider()
                        .padding()
                    
                    Button {
                        createCollection()
                    } label: {
                        ButtonView(text: "Create Collection", icon: "arrow.right")
                            .padding(.horizontal, 50)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(helper.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func createCollection() {
        if isFieldsFilled() {
            if isValidName() {
                let newCollection = Collection(id: UUID().uuidString, collectionName: collectionName, bgColorHex: selectedColorHex, dateCreated: Date(), tasks: nil, notes: nil)
                list.collections?.append(newCollection)
                dismiss()
            } else {
                helper.showAlertWithMessage("You already have a collection with this name for this List, please choose a different name for this collection.")
            }
        } else {
            helper.showAlertWithMessage("Please enter a name and choose a color for your Collection.")
        }
    }
    
    func isFieldsFilled() -> Bool {
        return !collectionName.isEmpty && !selectedColorHex.isEmpty
    }
    
    func isValidName() -> Bool {
        guard let collections = list.collections else { return true }
        return !collections.contains(where: { $0.collectionName.lowercased() == collectionName.lowercased() })
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
    AddCollectionView(helper: Helper(), list: $list)
}
