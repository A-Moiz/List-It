//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct AddListView: View {
    // MARK: - Properties
    @State var listName: String = ""
    @State var selectedColorHex: String = ""
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var lists: [List]
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "checklist.checked")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            Text("Create New List")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - List Content Card
                        VStack(spacing: 20) {
                            // MARK: - List Name Input
                            InputField(
                                icon: "checklist",
                                placeholder: "What's your list called?",
                                text: $listName
                            )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Customization Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .foregroundColor(.blue)
                                Text("Customization")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            // MARK: - Color Selection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "paintpalette")
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    Text("Choose a Color")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                
                                ColorSelectionView(
                                    colorHexes: AppConstants.listColorHexes,
                                    selectedHex: $selectedColorHex
                                )
                                
                                // MARK: - Selected Color Preview
                                if !selectedColorHex.isEmpty {
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(hex: selectedColorHex))
                                            .frame(width: 20, height: 20)
                                        Text("Selected: \(selectedColorHex)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: - Create Button
                        Button(action: createList) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                }
                                
                                Text(isLoading ? "Creating List..." : "Create List")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                            .opacity(isLoading ? 0.8 : 1.0)
                        }
                        .buttonStyle(PressedButtonStyle())
                        .disabled(isLoading)
                        .padding(.top, 8)
                        
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
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Cancel")
                                .font(.body)
                        }
                        .foregroundColor(.blue)
                    }
                    .disabled(isLoading)
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
    
    // MARK: - Creating List function
    func createList() {
        if isFieldsFilled() {
            if isValidName() {
                isLoading = true
                let trimmedDate = AppConstants.trimmedToMinute(Date()) ?? Date()
                let newList = List(id: UUID().uuidString, createdAt: trimmedDate, listIcon: "checklist", listName: listName, isDefault: false, bgColorHex: selectedColorHex, userId: "", isPinned: false)
                let generalCollection = Collection(id: UUID().uuidString, createdAt: trimmedDate, collectionName: "General", bgColorHex: selectedColorHex, listID: newList.id, userID: "")
                db.saveList(newList: newList, generalCollection: generalCollection) { success, error in
                    isLoading = false
                    if !success {
                        helper.showAlertWithMessage("Failed to save List: \(error)")
                    } else {
                        db.fetchUserLists { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching user lists: \(error)")
                            } else {
                                lists = db.lists
                            }
                        }
                        db.fetchUserCollections { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching collections: \(error)")
                            }
                        }
                        db.fetchUserTasks { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching and displaying new task: \(error)")
                            }
                        }
                        dismiss()
                    }
                }
            } else {
                helper.showAlertWithMessage("You already have a list with this name, please choose a different name for your new list.")
            }
        } else {
            helper.showAlertWithMessage("Please enter a name and choose a color for your List.")
        }
    }
    
    // MARK: - Checking if fields are blank
    func isFieldsFilled() -> Bool {
        return !listName.isEmpty && !selectedColorHex.isEmpty
    }
    
    // MARK: - Check if name is taken
    func isValidName() -> Bool {
        return !lists.contains(where: { $0.listName.lowercased() == listName.lowercased() })
    }
}

//#Preview {
//    @Previewable @State var lists = [
//        List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    ]
//    AddListView(helper: Helper(), db: Supabase(), lists: $lists)
//}
