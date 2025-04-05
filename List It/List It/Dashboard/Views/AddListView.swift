//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct AddListView: View {
    @State var listName: String = ""
    @State var selectedColorHex: String = ""
    @ObservedObject var helper: Helper
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var lists: [List]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    CustomTextField(icon: "checklist", placeholder: "List Name", text: $listName, isPassword: false, showPassword: false)
                    
                    ColorSelectionView(colorHexes: AppConstants.listColorHexes, selectedHex: $selectedColorHex)
                    
                    Text("Selected Color: \(selectedColorHex.isEmpty ? "None" : selectedColorHex)")
                        .font(.headline)
                        .foregroundColor(Color(hex: selectedColorHex.isEmpty ? "#A9A9A9" : selectedColorHex))
                    
                    Divider()
                        .padding()
                    
                    Button {
                        createList()
                    } label: {
                        ButtonView(text: "Create List", icon: "arrow.right")
                            .padding(.horizontal, 50)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add List")
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
    
    func createList() {
        if isFieldsFilled() {
            if isValidName() {
                let newList = List(id: UUID().uuidString, listName: listName, bgColorHex: selectedColorHex, dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
                lists.append(newList)
                dismiss()
            } else {
                helper.showAlertWithMessage("You already have a list with this name, please choose a different name for your new list.")
            }
        } else {
            helper.showAlertWithMessage("Please enter a name and choose a color for your List.")
        }
    }
    
    func isFieldsFilled() -> Bool {
        return !listName.isEmpty && !selectedColorHex.isEmpty
    }
    
    func isValidName() -> Bool {
        return !lists.contains(where: { $0.listName.lowercased() == listName.lowercased() })
    }
}

#Preview {
    @Previewable @State var lists = [
        List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
    ]
    AddListView(helper: Helper(), lists: $lists)
}
