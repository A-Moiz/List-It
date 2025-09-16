//
//  AllListsView.swift
//  List It
//
//  Created by Abdul Moiz on 07/05/2025.
//

import SwiftUI

struct AllListsView: View {
    // MARK: - Properties
    @State var searchText: String = ""
    @State var showAddListView: Bool = false
    @State var showAppearanceView: Bool = false
    @State var showSettingsView: Bool = false
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @State private var animatePinnedLists = false
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var refreshTrigger = UUID()
    @State private var headerAnimation = false
    @State private var isInitialLoad = true
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var combinedLists: [List] {
        let defaultLists = db.defaultLists.sorted { $0.createdAt < $1.createdAt }
        let userLists = db.lists.sorted { $1.createdAt > $0.createdAt }
        
        var seen = Set<String>()
        var result: [List] = []
        
        for list in defaultLists + userLists {
            if !seen.contains(list.id) {
                result.append(list)
                seen.insert(list.id)
            }
        }
        
        return result
    }
    
    var filteredLists: [List] {
        if searchText.isEmpty {
            return combinedLists
        } else {
            let filteredDefaults = db.defaultLists.filter { $0.listName.lowercased().contains(searchText.lowercased()) }
                .sorted(by: { $0.createdAt < $1.createdAt })
            let filteredUser = db.lists.filter { $0.listName.lowercased().contains(searchText.lowercased()) }
                .sorted(by: { $1.createdAt > $0.createdAt })
            return filteredDefaults + filteredUser
        }
    }
    
    var pinnedLists: [List] {
        filteredLists.filter { $0.isPinned }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color(UIColor.systemBackground).opacity(0.3) : Color(UIColor.systemBackground),
                        colorScheme == .dark ? Color.black.opacity(0.9) : Color(UIColor.systemBackground).opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(
                    ZStack {
                        ForEach(0..<20, id: \.self) { _ in
                            Circle()
                                .fill(colorScheme == .dark ? Color.blue.opacity(0.06) : Color.blue.opacity(0.03))
                                .frame(width: CGFloat.random(in: 50...200))
                                .position(
                                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                                )
                        }
                    }
                )
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 8) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 12) {
                        // MARK: - Welcome message
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Welcome Back")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.7) : Color.secondary)
                                    
                                    Text("👋")
                                        .font(.title2)
                                        .scaleEffect(headerAnimation ? 1.1 : 1.0)
                                }
                                
                                // MARK: - User's name
                                if let user = db.currentUser {
                                    Text(user.fullName)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    colorScheme == .dark ? .white : .black,
                                                    colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.8)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                } else {
                                    Text("Loading...")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                                }
                            }
                            
                            Spacer()
                            
                            // MARK: - Settings Button
                            Button {
                                showSettingsView = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "gear")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Settings")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(
                                                    colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                            }
                        }
                    }
                    .padding([.horizontal, .top])
                    .padding(.top, 8)
                    
                    // MARK: - Pinned Lists
                    if !pinnedLists.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "pin.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.yellow, Color.orange.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .font(.title3)
                                    .shadow(color: Color.yellow.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                Text("Pinned")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Spacer()
                                
                                Text("\(pinnedLists.count)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.yellow.opacity(0.8))
                                    )
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(pinnedLists, id: \.id) { list in
                                        PinnedListView(list: .constant(list), helper: helper, db: db)
                                            .scaleEffect(animatePinnedLists ? 1 : 0.95)
                                            .opacity(animatePinnedLists ? 1 : 0.7)
                                            .animation(
                                                .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)
                                                .delay(Double(pinnedLists.firstIndex(where: { $0.id == list.id }) ?? 0) * 0.1),
                                                value: animatePinnedLists
                                            )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    animatePinnedLists = true
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // MARK: - All Lists Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("All Lists")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            Text("\(filteredLists.count)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.purple.opacity(0.8))
                                )
                            
                            Spacer()
                            
                            // MARK: - Add Button
                            Button {
                                showAddListView = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                    
                                    Text("New List")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.purple.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Helper Text
                        HStack {
                            Text("💡 Swipe down to refresh • Hold lists for more options")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        
                        // MARK: - Search Bar
                        CustomSearchBar(searchText: $searchText, prompt: "Search your Lists...")
                    }
                    .padding(.top, 12)
                    
                    // MARK: - Lists Grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredLists, id: \.id) { list in
                                ListView(
                                    list: Binding(
                                        get: {
                                            if let updatedList = combinedLists.first(where: { $0.id == list.id }) {
                                                return updatedList
                                            }
                                            return list
                                        },
                                        set: { newValue in
                                            if let index = db.lists.firstIndex(where: { $0.id == newValue.id }) {
                                                db.lists[index] = newValue
                                            } else if let index = db.defaultLists.firstIndex(where: { $0.id == newValue.id }) {
                                                db.defaultLists[index] = newValue
                                            }
                                            refreshTrigger = UUID()
                                        }
                                    ),
                                    helper: helper,
                                    db: db
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.5, dampingFraction: 0.8)),
                                    removal: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.3))
                                ))
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                    }
                    .id(refreshTrigger)
                }
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showAddListView) {
                AddListView(helper: helper, db: db, lists: $db.lists)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView(helper: helper, db: db)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
            .refreshable {
                await refreshData()
            }
            .onAppear {
                headerAnimation = true
                if isInitialLoad && db.currentUser == nil {
                    Task {
                        await initialDataLoad()
                    }
                }
                isInitialLoad = false
            }
        }
    }
    
    // MARK: - Initial Data Load
    @MainActor
    private func initialDataLoad() async {
        await withCheckedContinuation { continuation in
            db.fetchCurrentUser { success, error in
                if !success {
                    helper.showAlertWithMessage("Error fetching User details. Please refresh the page. \(error ?? "Unknown error")")
                }
                continuation.resume()
            }
        }
        
        guard db.currentUser != nil else {
            db.signOutUser { success, error in
                if !success {
                    helper.showAlertWithMessage("No user found. Please sign in again.")
                } else {
                    isSignedIn = false
                    
                }
            }
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserLists { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error loading user Lists: \(error)")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserCollections { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching user Collections: \(error)")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserTasks { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching user Tasks: \(error)")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserNotes { success, errorMessage in
                            if !success, let error = errorMessage {
                                if error.contains("No user ID found") {
                                    helper.showAlertWithMessage("No user Notes found: \(error)")
                                } else {
                                    helper.showAlertWithMessage("Error fetching notes: \(error)")
                                    DispatchQueue.main.async {
                                        helper.showAlertWithMessage("Error fetching Notes: \(error)")
                                    }
                                }
                            }
                            continuation.resume()
                        }
                    }
                }
            }
        }
        refreshTrigger = UUID()
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func refreshData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchCurrentUser { success, error in
                            if !success {
                                helper.showAlertWithMessage("Error fetching user details: \(error ?? "Unknown Error")")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserLists { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching user Lists: \(error)")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserCollections { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching Collections: \(error)")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserTasks { success, errorMessage in
                            if !success, let error = errorMessage {
                                helper.showAlertWithMessage("Error fetching and displaying new Task: \(error)")
                            }
                            continuation.resume()
                        }
                    }
                }
            }
            
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        db.fetchUserNotes { success, errorMessage in
                            if !success, let error = errorMessage {
                                if !error.contains("No user ID found") {
                                    helper.showAlertWithMessage("Error fetching and displaying new Note: \(error)")
                                }
                            }
                            continuation.resume()
                        }
                    }
                }
            }
        }
        refreshTrigger = UUID()
    }
}
