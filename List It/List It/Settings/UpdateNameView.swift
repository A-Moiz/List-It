//
//  UpdateNameView.swift
//  List It
//
//  Created by Abdul Moiz on 31/05/2025.
//

import SwiftUI

struct UpdateNameView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var editedName: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 8) {
                    // MARK: - User Name
                    Text("USER NAME")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                        .padding(.horizontal, 4)
                    
                    // MARK: - Name textfield
                    TextField("User name...", text: $editedName)
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                        )
                    
                    // MARK: - Save button
                    Button {
                        if editedName.isEmpty {
                            helper.showAlertWithMessage("Name cannot be empty")
                        } else {
                            withAnimation {
                                db.updateName(name: editedName) { success, error in
                                    if !success {
                                        helper.showAlertWithMessage("Error updating Name: \(error ?? "Unknown error")")
                                    } else {
                                        db.fetchCurrentUser { success, error in
                                            if !success {
                                                helper.showAlertWithMessage("Error fetching updated: \(error ?? "Unknown error")")
                                            }
                                        }
                                        dismiss()
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "87CEEB"),
                                        Color(hex: "4682B4"),
                                        Color(hex: "1E3A8A")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .navigationTitle("Update Name")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                editedName = db.currentUser?.fullName ?? ""
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(helper.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.7))
                    }
                }
            }
        }
    }
}
