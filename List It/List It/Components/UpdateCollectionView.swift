//
//  UpdateCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 10/06/2025.
//

import SwiftUI

struct UpdateCollectionView: View {
    // MARK: - Properties
    @State var collectionName: String = ""
    @State var selectedColorHex: String = ""
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State var isLoading: Bool = false
    let collection: Collection
    let list: List
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            Text("Update Collection")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Collection Content Card
                        VStack(spacing: 20) {
                            // MARK: - Collection Name Input
                            InputField(
                                icon: "checklist",
                                placeholder: "What's your list called?",
                                text: $collectionName
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
                        
                        // MARK: - Update Button
                        Button(action: updateList) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                }
                                
                                Text(isLoading ? "Updating Collection..." : "Update Collection")
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
                        .disabled(isLoading || collectionName.isEmpty)
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.body)
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
        .onAppear {
            collectionName = collection.collectionName
            selectedColorHex = collection.bgColorHex
        }
    }
    
    // MARK: - Update List function
    func updateList() {
        if isFieldsFilled() {
            if isValidName(for: list.id) {
                isLoading = true
                db.updateCollection(collection: collection, name: collectionName, bgColorHex: selectedColorHex) { success, error in
                    if !success, let errorMessage = error {
                        isLoading = false
                        helper.showAlertWithMessage("\(errorMessage)")
                    } else {
                        db.fetchUserCollections { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching Collections: \(error)")
                            }
                        }
                        dismiss()
                    }
                }
            } else {
                helper.showAlertWithMessage("You already have a Collection with this name, please choose a different name.")
            }
        }
    }
    
    // MARK: - Checking if field is blank
    func isFieldsFilled() -> Bool {
        return !collectionName.isEmpty
    }
    
    // MARK: - Check if collection already exists
    func isValidName(for listId: String) -> Bool {
        let newName = collectionName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return !db.collections.contains { existing in
            existing.listID == list.id &&
            existing.id != collection.id &&
            existing.collectionName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() == newName
        }
    }
}
