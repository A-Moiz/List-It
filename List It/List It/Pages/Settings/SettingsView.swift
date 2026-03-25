//
//  SettingsView.swift
//  List It
//
//  Created by Abdul Moiz on 04/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    @State var showEditNameView: Bool = false
    @State var showActivityView: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ProfileSection()
                    .padding(.top)
                
                ActionButtonsView(showEditNameView: $showEditNameView, showActivityView: $showActivityView)
                    .padding(.horizontal)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
            }
            .sheet(isPresented: $showEditNameView) {
                EditNameView()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(25)
            }
            .sheet(isPresented: $showActivityView) {
                ActivityView()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
        }
    }
}

// MARK: - Settings Profile section
struct ProfileSection: View {
    @Environment(Supabase.self) var db
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    if let user = db.currentUser, let createdAt = user.createdAt {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.headline)
                            
                            Text("Joined: \(db.formattedDate(createdAt))")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
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
    }
}

// MARK: - Settings action button views
struct SettingsButtonView: View {
    @State var image: String
    @State var imageColor: Color
    @State var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundStyle(imageColor)
            Text(text)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - All buttons view
struct ActionButtonsView: View {
    @Binding var showEditNameView: Bool
    @Binding var showActivityView: Bool
    @Environment(Supabase.self) var db
    @State var showAlert: Bool = false
    @State var alertMode: AlertMode = .error
    private var alertTitle: String {
        alertMode == .delete ? "Delete Account?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    
    var body: some View {
        VStack {
            Button {
                showEditNameView = true
            } label: {
                SettingsButtonView(image: "pencil", imageColor: .pink, text: "Edit Name")
            }
            
            Divider()
            
            Button {
                showActivityView = true
            } label: {
                SettingsButtonView(image: "person.text.rectangle", imageColor: .purple, text: "View Activity")
            }
            
            Divider()
            
            Button {
                if let url = URL(string: "https://list-it-dom.netlify.app/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsButtonView(image: "globe", imageColor: .blue, text: "View Website")
            }
            
            Divider()
            
            Button {
                Task {
                    await db.signOutUser()
                }
            } label: {
                SettingsButtonView(image: "rectangle.portrait.and.arrow.right", imageColor: .orange, text: "Sign Out")
            }
            
            Divider()
            
            Button {
                alertMode = .delete
                showAlert = true
            } label: {
                SettingsButtonView(image: "trash", imageColor: .red, text: "Delete Account")
            }
            
            Divider()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if alertMode == .delete {
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount() {
        Task {
            let success = await db.deleteAccount()
            
            if !success {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(Supabase())
}
