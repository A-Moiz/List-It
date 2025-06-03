//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct AddCollectionView: View {
    // MARK: - Properties
    @State var collectionName: String = ""
    @State var selectedColorHex: String = ""
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var list: List
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // MARK: - Header Section
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Create Collection")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Organize your tasks and notes with a custom collection")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Collection Name Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "textformat.abc")
                                    .foregroundColor(.blue)
                                Text("Collection Name")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            ModernTextField(
                                icon: "folder",
                                placeholder: "Enter collection name...",
                                text: $collectionName
                            )
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
                        )
                        
                        // MARK: - Color Selection Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "paintpalette")
                                    .foregroundColor(.purple)
                                Text("Choose Color")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            ColorSelectionView(
                                colorHexes: AppConstants.listColorHexes,
                                selectedHex: $selectedColorHex
                            )
                            
                            // MARK: - Color Preview
                            if !selectedColorHex.isEmpty {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: selectedColorHex))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
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
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
                        )
                        
                        // MARK: - Create Button
                        Button(action: createCollection) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Create Collection")
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
                                            colors: [.purple, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
                            )
                        }
                        .buttonStyle(PressedButtonStyle())
                        .disabled(collectionName.isEmpty || selectedColorHex.isEmpty)
                        .opacity(collectionName.isEmpty || selectedColorHex.isEmpty ? 0.6 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: collectionName.isEmpty || selectedColorHex.isEmpty)
                        
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
    
    // MARK: - Create collection
    func createCollection() {
        if isFieldsFilled() {
            if isValidName() {
                let createdDate = db.dateAndTime(Date())
                let newCollection = Collection(id: UUID().uuidString, createdAt: createdDate ?? Date(), collectionName: collectionName, bgColorHex: selectedColorHex, listID: list.id, userID: "")
                db.saveCollection(newCollection: newCollection) { success, error in
                    if !success {
                        helper.showAlertWithMessage("Failed to create General Collection within List: \(error ?? "Unknown error")")
                    } else {
                        db.fetchUserCollections { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching collections: \(error)")
                            }
                        }
                        dismiss()
                    }
                }
            } else {
                helper.showAlertWithMessage("You already have a collection with this name for this List, please choose a different name for your new collection.")
            }
        } else {
            helper.showAlertWithMessage("Please enter a name and choose a color your new Collection.")
        }
    }
    
    // MARK: - Check if fields are blank
    func isFieldsFilled() -> Bool {
        return !collectionName.isEmpty && !selectedColorHex.isEmpty
    }
    
    // MARK: - Check if collection already exists
    func isValidName() -> Bool {
        return !db.collections.contains(where: { $0.collectionName.lowercased() == collectionName.lowercased() })
    }
}

//#Preview {
//    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    AddCollectionView(helper: Helper(), db: Supabase(), list: $list)
//}
