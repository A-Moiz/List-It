//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct AddCollectionView: View {
    @State var collectionName: String = ""
    @State var selectedColor: Color = .clear
    @ObservedObject var helper: Helper
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var collections: [Collection]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    CustomTextField(icon: "checklist", placeholder: "Collection Name", text: $collectionName, isPassword: false, showPassword: false)
                    
                    ColorSelectionView(colors: AppConstants.collectionColors, selectedColor: $selectedColor)
                    
                    Text("Selected Color: \(selectedColor.description.capitalized)")
                        .font(.headline)
                        .foregroundColor(selectedColor == .clear ? .gray : selectedColor)
                    
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
                let newCollection = Collection(
                    id: NSUUID().uuidString,
                    collectionName: collectionName,
                    bgColor: selectedColor,
                    dateCreated: Date(),
                    isDefault: false,
                    tasks: [],
                    notes: []
                )
                collections.append(newCollection)
                dismiss()
            } else {
                helper.showAlertWithMessage("You already have a collection with this name, please choose a different name for your new collection.")
            }
        } else {
            helper.showAlertWithMessage("Please enter a name and choose a color for your Collection.")
        }
    }
    
    func isFieldsFilled() -> Bool {
        return !collectionName.isEmpty && selectedColor != .clear
    }
    
    func isValidName() -> Bool {
        return !collections.contains(where: { $0.collectionName.lowercased() == collectionName.lowercased() })
    }
}

#Preview {
    @Previewable @State var collections = [
        Collection(id: NSUUID().uuidString, collectionName: "Today", bgColor: .orange, dateCreated: Date(), isDefault: true),
        Collection(id: NSUUID().uuidString, collectionName: "Completed", bgColor: .green, dateCreated: Date(), isDefault: true),
        Collection(id: NSUUID().uuidString, collectionName: "Not Completed", bgColor: .red, dateCreated: Date(), isDefault: true)
    ]
    AddCollectionView(helper: Helper(), collections: $collections)
}
