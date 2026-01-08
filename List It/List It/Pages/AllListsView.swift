//
//  AllListsView.swift
//  List It
//
//  Created by Abdul Moiz on 03/01/2026.
//

import SwiftUI

struct AllListsView: View {
    @Environment(Supabase.self) var db
    @Environment(\.colorScheme) var colorScheme
    @State var searchText: String = ""
    @State var showSettings: Bool = false
    @State var showAddListView: Bool = false
    @State var showUpdateListView: Bool = false
    @State var viewingList: List?
    @State var showAlert: Bool = false
    @State var alertMode: AlertMode = .error
    @State var selectedListToDelete: List?
    @State var selectedListToUpdate: List?
    @State var columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    var filteredLists: [List] {
        db.getFilteredLists(query: searchText)
    }
    private var alertTitle: String {
        alertMode == .delete ? "Delete List?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HeaderView(showSettings: $showSettings)
                    .padding()
                
                PinnedListView(viewingList: $viewingList, showUpdateListView: $showUpdateListView, selectedListToDelete: $selectedListToDelete, selectedListToUpdate: $selectedListToUpdate, alertMode: $alertMode, showAlert: $showAlert, searchText: $searchText)
                    .padding()
                
                ListInfoSection(showAddListView: $showAddListView)
                    .padding()
                
                Rectangle()
                    .fill(colorScheme == .dark
                          ? Color.white.opacity(0.5)
                          : Color.black.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredLists) { list in
                        ListView(list: list)
                            .id("\(list.id)-\(list.listName)-\(list.bgColorHex)")
                            .padding(.horizontal, 5)
                            .onTapGesture  {
                                viewingList = list
                            }
                            .contextMenu {
                                if list.isDefault {
                                    Button {
                                        Task {
                                            await db.updateListPin(list: list, isPinned: !list.isPinned)
                                        }
                                    } label: {
                                        Label(
                                            list.isPinned ? "Unpin List" : "Pin List",
                                            systemImage: list.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                } else {
                                    Button {
                                        Task {
                                            await db.updateListPin(list: list, isPinned: !list.isPinned)
                                        }
                                    } label: {
                                        Label(
                                            list.isPinned ? "Unpin List" : "Pin List",
                                            systemImage: list.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                    
                                    Button {
                                        selectedListToUpdate = list
                                        showUpdateListView = true
                                    } label: {
                                        Label("Update List", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        selectedListToDelete = list
                                        alertMode = .delete
                                        showAlert = true
                                    } label: {
                                        Label("Delete List", systemImage: "trash")
                                    }
                                }
                            }
                    }
                }
            }
            .navigationTitle("Welcome Back 👋")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search your Lists")
            .alert(alertTitle, isPresented: $showAlert) {
                if alertMode == .delete {
                    Button("Delete", role: .destructive) {
                        performDelete()
                    }
                    Button("Cancel", role: .cancel) { }
                } else {
                    Button("OK", role: .cancel) { }
                }
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(item: $viewingList) { list in
                ListDetailView(list: list)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
            .sheet(isPresented: $showAddListView) {
                AddListView(lists: filteredLists)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
            .sheet(item: $selectedListToUpdate) { list in
                UpdateListView(list: list)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
            }
        }
    }
    
    // MARK: - Delete List
    func performDelete() {
        guard let listToDelete = selectedListToDelete else {
            alertMode = .error
            db.setError(title: "Error", message: "No List selected for deletion")
            showAlert = true
            print("DEBUG: No list selected for deletion")
            return
        }
        
        Task {
            let success = await db.deleteList(list: listToDelete)
            
            if !success {
                await MainActor.run {
                    alertMode = .error
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Lists view
struct ListView: View {
    @Environment(\.colorScheme) var colorScheme
    var list: List
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? .black : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(list.bgColor, lineWidth: 1.5)
                )
                .frame(height: 100)
                .shadow(color: list.bgColor.opacity(colorScheme == .dark ? 0.5 : 0.3), radius: 3, x: 0, y: 2)
            
            VStack {
                ListIconView(list: list)
                    .padding(.top, 12)
                
                Spacer()
                
                ListInfo(list: list, isPinnedList: false)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            
            ListSideBar(list: list)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - List icon view
struct ListIconView: View {
    var list: List
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [list.bgColor, list.bgColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 30)
            
            Image(systemName: list.isDefault ? list.listIcon : "checklist")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - List info
struct ListInfo: View {
    var list: List
    @Environment(Supabase.self) var db
    var isPinnedList: Bool
    
    var body: some View {
        VStack {
            Text(list.listName)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(3)
                .multilineTextAlignment(.center)
            
            let taskCount = db.tasks.filter { $0.listID == list.id && !$0.isDeleted && !$0.isCompleted }.count
            let noteCount = db.notes.filter { $0.listID == list.id && !$0.isDeleted }.count
            
            if !list.isDefault && !isPinnedList {
                Text("\(taskCount) \(taskCount == 1 ? "Task" : "Tasks") • \(noteCount) \(noteCount == 1 ? "Note" : "Notes")")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
            }
        }
    }
}

// MARK: - List side bar
struct ListSideBar: View {
    var list: List
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(list.bgColor)
                .frame(width: 5)
                .padding(.vertical, 10)
        }
    }
}

// MARK: - List info section
struct ListInfoSection: View {
    @Binding var showAddListView: Bool
    @Environment(Supabase.self) var db
    
    var body: some View {
        VStack {
            HStack {
                Text("All Lists")
                    .font(.system(size: 24, weight: .bold))
                
                Text(String((db.defaultLists + db.lists).count))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange)
                    )
                
                Spacer()
                
                Button {
                    showAddListView = true
                } label: {
                    ListButtonView(image: "plus", text: "New List")
                }
            }
            
            Text("💡 Holds Lists for more options")
                .font(.caption)
        }
    }
}

// MARK: - Lists header view
struct HeaderView: View {
    @Environment(Supabase.self) var db
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            if let user = db.currentUser {
                Text(user.name)
                    .font(.system(size: 20, weight: .bold))
            } else {
                Text("Loading...")
                    .font(.system(size: 20, weight: .bold))
            }
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                ListButtonView(image: "gear", text: "Settings")
            }
        }
    }
}

// MARK: - List Button view
struct ListButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var image: String
    @State var text: String
    
    var body: some View {
        HStack {
            Image(systemName: image)
            Text(text)
                .font(.system(size: 14, weight: .regular))
        }
        .foregroundStyle(colorScheme == .dark ? .white : .black)
        .padding(10)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                .overlay(
                    Capsule()
                        .strokeBorder(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), lineWidth: 2)
                )
        )
    }
}

// MARK: - Pinned Lists View
struct PinnedListView: View {
    @Environment(Supabase.self) var db
    @Binding var viewingList: List?
    @Environment(\.colorScheme) var colorScheme
    @Binding var showUpdateListView: Bool
    @Binding var selectedListToDelete: List?
    @Binding var selectedListToUpdate: List?
    @Binding var alertMode: AlertMode
    @Binding var showAlert: Bool
    @Binding var searchText: String

    var pinnedLists: [List] {
        db.pinnedLists(query: searchText)
    }
    var body: some View {
        Group {
            if !pinnedLists.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    PinnedHeaderView(pinnedLists: pinnedLists)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(pinnedLists) { list in
                                PinnedListCard(list: list)
                                    .id("\(list.id)-\(list.listName)-\(list.bgColorHex)")
                                    .onTapGesture { viewingList = list }
                                    .contextMenu {
                                        if list.isDefault {
                                            Button {
                                                Task {
                                                    await db.updateListPin(list: list, isPinned: !list.isPinned)
                                                }
                                            } label: {
                                                Label(
                                                    list.isPinned ? "Unpin List" : "Pin List",
                                                    systemImage: list.isPinned ? "pin.slash" : "pin"
                                                )
                                            }
                                        } else {
                                            Button {
                                                Task {
                                                    await db.updateListPin(list: list, isPinned: !list.isPinned)
                                                }
                                            } label: {
                                                Label(
                                                    list.isPinned ? "Unpin List" : "Pin List",
                                                    systemImage: list.isPinned ? "pin.slash" : "pin"
                                                )
                                            }
                                            
                                            Button {
                                                selectedListToUpdate = list
                                                showUpdateListView = true
                                            } label: {
                                                Label("Update List", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                selectedListToDelete = list
                                                alertMode = .delete
                                                showAlert = true
                                            } label: {
                                                Label("Delete List", systemImage: "trash")
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
        }
    }
}

// MARK: - Pinned header section
struct PinnedHeaderView: View {
    let pinnedLists: [List]
    
    var body: some View {
        HStack {
            Text("Pinned Lists")
                .font(.system(size: 24, weight: .bold))
            
            Text(String((pinnedLists).count))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.orange)
                )
            
            Spacer()
        }
    }
}

// MARK: - Pinned Lists card
struct PinnedListCard: View {
    let list: List
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(list.bgColor, lineWidth: 1.5)
                )
            
            HStack(spacing: 0) {
                ListSideBar(list: list)
                    .frame(width: 4)
                
                HStack(spacing: 12) {
                    ListIconView(list: list)
                    ListInfo(list: list, isPinnedList: true)
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 50)
        .fixedSize(horizontal: true, vertical: false)
        .shadow(
            color: list.bgColor.opacity(colorScheme == .dark ? 0.5 : 0.2),
            radius: 3, x: 0, y: 2
        )
    }
}

#Preview {
    @Previewable @State var list: List = List(id: "", createdAt: Date(), listIcon: "", listName: "Test List", isDefault: false, bgColorHex: "", userId: "", isPinned: false)
    
    AllListsView()
        .environment(Supabase())
}
