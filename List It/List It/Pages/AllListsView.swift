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
    @State var showWhatsNewView: Bool = false
    @State var viewingList: List?
    @State var showAlert: Bool = false
    @State var alertMode: AlertMode = .error
    @State var selectedListToDelete: List?
    @State var selectedListToUpdate: List?
    @State private var currentSort: SortOption = .oldest
    @State var columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    @State private var selectedQuickAction: QuickAction?
    var filteredLists: [List] {
        db.getFilteredLists(query: searchText, sort: currentSort)
    }
    
    private var alertTitle: String {
        alertMode == .delete ? "Delete List?" : db.alertTitle
    }
    
    private var alertMessage: String {
        alertMode == .delete ? "This action cannot be undone." : db.alertMessage
    }
    @AppStorage("listDisplayStyle") private var displayStyle: ListDisplayStyle = .card
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenVersion: Int = 0
    @State var currentVersion: Int = 3
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                    .padding()
                
                PinnedListView(viewingList: $viewingList, showUpdateListView: $showUpdateListView, selectedListToDelete: $selectedListToDelete, selectedListToUpdate: $selectedListToUpdate, alertMode: $alertMode, showAlert: $showAlert, searchText: $searchText)
                    .padding()
                
                ListInfoSection(showAddListView: $showAddListView, currentSort: $currentSort, showWhatsNewView: $showWhatsNewView, currentVersion: currentVersion)
                    .padding()
                
                Rectangle()
                    .fill(colorScheme == .dark
                          ? Color.white.opacity(0.5)
                          : Color.black.opacity(0.5))
                    .frame(height: 2)
                    .padding(.horizontal)
                    .padding(.bottom, 1)
                
                Group {
                    if filteredLists.isEmpty {
                        ScrollView {
                            ContentUnavailableView {
                                Label("No Lists", systemImage: "checklist")
                            } description: {
                                Text("Create a List to start organising your tasks and notes.")
                            } actions: {
                                Button {
                                    showAddListView = true
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Create List")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        switch displayStyle {
                        case .card:
                            ScrollView {
                                cardGrid
                            }
                        case .list:
                            rowList
                        }
                    }
                }
            }
            .navigationTitle("Welcome Back 👋")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                requestNotificationPermission()
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // Settings
                        Button {
                            showSettings = true
                        } label: {
                            ListButtonView(image: "gear", text: "Settings")
                        }
                        
                        Divider()
                        
                        // Create List
                        Button {
                            showAddListView = true
                        } label: {
                            Label("Create List", systemImage: "plus")
                        }
                        
                        Divider()
                        
                        // Default Lists
                        Button {
                            selectedQuickAction = .today
                        } label: {
                            Label("Today's Tasks", systemImage: "calendar")
                        }
                        
                        Button {
                            selectedQuickAction = .tomorrow
                        } label: {
                            Label("Tomorrow's Tasks", systemImage: "calendar.badge.clock")
                        }
                        
                        Button {
                            selectedQuickAction = .priority
                        } label: {
                            Label("Priority Tasks", systemImage: "star.fill")
                        }
                        
                        Button {
                            selectedQuickAction = .completed
                        } label: {
                            Label("Completed Tasks", systemImage: "checkmark.circle")
                        }
                        
                        Button {
                            selectedQuickAction = .notCompleted
                        } label: {
                            Label("Not Completed Tasks", systemImage: "circle")
                        }
                        
                        Button {
                            selectedQuickAction = .overdue
                        } label: {
                            Label("Overdue Tasks", systemImage: "exclamationmark.circle")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
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
            .navigationDestination(item: $selectedQuickAction) { action in
                switch action {
                case .today:
                    TodayView()
                case .tomorrow:
                    TomorrowView()
                case .priority:
                    PriorityView()
                case .completed:
                    CompletedView()
                case .notCompleted:
                    NotCompletedView()
                case .overdue:
                    OverdueView()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showAddListView) {
                AddListView(lists: filteredLists)
                    .presentationDetents([.medium])
                    .interactiveDismissDisabled()
            }
            .sheet(item: $selectedListToUpdate) { list in
                UpdateListView(list: list)
                    .presentationDetents([.medium])
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showWhatsNewView) {
                WhatsNewView(currentVersion: currentVersion)
                    .presentationDetents([.medium, .large])
                    .interactiveDismissDisabled()
            }
        }
    }
    
    // MARK: - List Context menu
    @ViewBuilder
    private func listContextMenu(for list: List) -> some View {
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
    
    // MARK: - List card style
    @ViewBuilder
    private var cardGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(filteredLists) { list in
                ListView(list: list)
                    .id("\(list.id)-\(list.listName)-\(list.bgColorHex)")
                    .onTapGesture {
                        viewingList = list
                    }
                    .contextMenu {
                        listContextMenu(for: list)
                    }
            }
        }
        .padding(.top)
    }
    
    // MARK: - List row style
    @ViewBuilder
    private var rowList: some View {
        SwiftUI.List {
            ForEach(filteredLists) { list in
                ListRowView(list: list)
                    .id("\(list.id)-\(list.listName)-\(list.bgColorHex)")
                    .onTapGesture {
                        viewingList = list
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            selectedListToDelete = list
                            alertMode = .delete
                            showAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        
                        Button {
                            selectedListToUpdate = list
                            showUpdateListView = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                        
                        Button {
                            Task { await db.updateListPin(list: list, isPinned: !list.isPinned) }
                        } label: {
                            Label {
                                Text(list.isPinned ? "Unpin" : "Pin")
                            } icon: {
                                Image(systemName: list.isPinned ? "pin.slash.fill" : "pin.fill")
                            }
                        }
                        .tint(.orange)
                    }
                    .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Delete List
    func performDelete() {
        guard let listToDelete = selectedListToDelete else {
            alertMode = .error
            db.setError(title: "Error", message: "No List selected for deletion")
            showAlert = true
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
    
    // MARK: - Requesting notification
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Permission error: \(error)")
            }
            print("Permission granted: \(granted)")
        }
    }
}

// MARK: - Lists view (rounded rectangle)
struct ListView: View {
    @Environment(\.colorScheme) var colorScheme
    var list: List
    private let cornerRadius: CGFloat = 6
    
    var body: some View {
        VStack {
            ListInfo(list: list, isPinnedList: false, isRowView: false)
                .padding(.horizontal)
        }
        .frame(width: 120, height: 70)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(list.bgColor.opacity(0.2)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(list.bgColor, lineWidth: 1.5)
        )
        .overlay(alignment: .leading) {
            ListSideBar(list: list, isPinnedList: false)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: list.bgColor.opacity(colorScheme == .dark ? 0.5 : 0.3), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Lists view (row)
struct ListRowView: View {
    @Environment(\.colorScheme) var colorScheme
    var list: List
    
    private let cornerRadius: CGFloat = 14
    
    var body: some View {
        HStack(spacing: 14) {
            ListInfo(list: list, isPinnedList: false, isRowView: true)
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(list.bgColor.opacity(0.2)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(list.bgColor, lineWidth: 1.5)
        )
        .overlay(alignment: .leading) {
            ListSideBar(list: list, isPinnedList: false)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: list.bgColor.opacity(colorScheme == .dark ? 0.5 : 0.3), radius: 3, x: 0, y: 2)
    }
}

// MARK: - List info
struct ListInfo: View {
    var list: List
    @Environment(Supabase.self) var db
    var isPinnedList: Bool
    var isRowView: Bool
    
    var body: some View {
        if isRowView {
            VStack(alignment: .leading, spacing: 5) {
                Text(list.listName)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                
                let taskCount = db.tasks.filter { $0.listID == list.id && !$0.isDeleted && !$0.isCompleted }.count
                let noteCount = db.notes.filter { $0.listID == list.id && !$0.isDeleted }.count
                
                if !list.isDefault && !isPinnedList {
                    Text("\(taskCount) \(taskCount == 1 ? "Task" : "Tasks") • \(noteCount) \(noteCount == 1 ? "Note" : "Notes")")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(.lightGray))
                }
            }
        } else {
            VStack(spacing: 2) {
                Text(list.listName)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                
                let taskCount = db.tasks.filter { $0.listID == list.id && !$0.isDeleted && !$0.isCompleted }.count
                let noteCount = db.notes.filter { $0.listID == list.id && !$0.isDeleted }.count
                
                if !list.isDefault && !isPinnedList {
                    Text("\(taskCount) \(taskCount == 1 ? "Task" : "Tasks") • \(noteCount) \(noteCount == 1 ? "Note" : "Notes")")
                        .font(.system(size: 8))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

// MARK: - List side bar
struct ListSideBar: View {
    var list: List
    var isPinnedList: Bool
    
    var body: some View {
        Rectangle()
            .fill(list.bgColor)
            .frame(width: isPinnedList ? 3 : 5)
    }
}

// MARK: - List info section
struct ListInfoSection: View {
    @Binding var showAddListView: Bool
    @Binding var currentSort: SortOption
    @Environment(Supabase.self) var db
    @Binding var showWhatsNewView: Bool
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenVersion: Int = 0
    @State var currentVersion: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Your Lists")
                    .font(.system(size: 24, weight: .bold))
                
                Text(String((db.lists).count))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange)
                    )
                
                Spacer()
                
                Menu {
                    Picker("Sort Lists", selection: $currentSort) {
                        Label("Oldest", systemImage: "calendar").tag(SortOption.oldest)
                        Label("Newest", systemImage: "calendar.badge.plus").tag(SortOption.newest)
                        Label("A-Z", systemImage: "textformat.characters").tag(SortOption.alphabeticalAZ)
                        Label("Z-A", systemImage: "textformat.characters").tag(SortOption.alphabeticalZA)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                }
            }
            
            if lastSeenVersion < currentVersion {
                Button {
                    showWhatsNewView = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("See what's new")
                    }
                }
            }
        }
    }
}

// MARK: - Lists header view
struct HeaderView: View {
    @Environment(Supabase.self) var db
    
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
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(list.bgColor.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(list.bgColor, lineWidth: 1.5)
                )
            
            HStack(spacing: 0) {
                ListSideBar(list: list, isPinnedList: true)
                    .frame(width: 4)
                
                HStack {
                    ListInfo(list: list, isPinnedList: true, isRowView: false)
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 40)
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
