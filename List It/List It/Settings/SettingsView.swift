//
//  SettingsView.swift
//  List It
//
//  Created by Abdul Moiz on 31/05/2025.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State var showUpdateNameView: Bool = false
    @State var showActivityView: Bool = false
    @State var showDeleteAccountMessage: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    // MARK: - Profile Section
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            if let user = db.currentUser, let createdAt = user.createdAt {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.fullName)
                                        .font(.headline)
                                    
                                    Text("Joined: \(db.formattedDate(createdAt))")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                    
                    // MARK: - Action Buttons
                    VStack(spacing: 1) {
                        Button(action: {
                            showUpdateNameView = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.orange)
                                Text("Edit Name")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                        
                        Button(action: {
                            showActivityView = true
                        }) {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.orange)
                                Text("View Activity")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://list-it-dom.netlify.app/") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.blue)
                                Text("View Website")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                        
                        Button(action: {
                            dismiss()
                            db.signOutUser { success, error in
                                if success {
                                    db.resetFields()
                                    isSignedIn = false
                                } else {
                                    helper.showAlertWithMessage("\(error ?? "Unknown error")")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                Text("Sign Out")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                        
                        Button(action: {
                            showDeleteAccountMessage = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete Account")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                if showDeleteAccountMessage {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Text("Are you sure you want to delete your account?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            Button("Cancel") {
                                showDeleteAccountMessage = false
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                            
                            Button("Delete") {
                                showDeleteAccountMessage = false
                                db.deleteAccount { success, error in
                                    if success {
                                        db.signOutUser { signOutSuccess, signOutError in
                                            DispatchQueue.main.async {
                                                if signOutSuccess {
                                                    db.resetFields()
                                                    isSignedIn = false
                                                    dismiss()
                                                } else {
                                                    helper.showAlertWithMessage("\(signOutError ?? "Unknown error")")
                                                }
                                            }
                                        }
                                    } else {
                                        helper.showAlertWithMessage("\(error ?? "Unknown error")")
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 40)
                }
            }
            .animation(.easeInOut, value: showDeleteAccountMessage)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showUpdateNameView) {
                UpdateNameView(db: db, helper: helper)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showActivityView) {
                ActivityView(db: db, helper: helper)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
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
