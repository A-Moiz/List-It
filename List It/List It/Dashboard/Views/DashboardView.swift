//
//  DashboardView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

//struct DashboardView: View {
//    @State var searchText: String = ""
//    @State var showAddListView: Bool = false
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//    var filteredLists: [List] {
//        if searchText.isEmpty {
//            return db.lists
//        } else {
//            return db.lists.filter { list in
//                list.listName.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppConstants.background(for: colorScheme)
//                    .ignoresSafeArea()
//                
//                VStack(alignment: .leading, spacing: 10) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Welcome Back 👋")
//                            .font(.title3)
//                            .fontWeight(.medium)
//                        
//                        Text("Explore Your Lists")
//                            .font(.largeTitle)
//                            .bold()
//                    }
//                    .padding()
//                    
//                    Text("Pinned Lists")
//                        .bold()
//                        .font(.title2)
//                        .padding(.horizontal)
//                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 15) {
//                            ForEach(filteredLists, id: \.id) { list in
//                                if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
//                                    let binding = Binding<List>(
//                                        get: { db.lists[index] },
//                                        set: { db.lists[index] = $0 }
//                                    )
//                                    PinnedListView(list: binding, helper: helper, db: db)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 15)
//                    }
//                    .padding(.bottom)
//                    
//                    HStack {
//                        Text("Your Lists")
//                            .bold()
//                        Spacer()
//                        Button {
//                            showAddListView = true
//                        } label: {
//                            Image(systemName: "plus.circle.fill")
//                        }
//                    }
//                    .font(.title2)
//                    .padding(.horizontal)
//                    
//                    CustomSearchBar(text: $searchText, prompt: "Search List...")
//                    
//                    ScrollView {
//                        VStack(spacing: 15) {
//                            ForEach(filteredLists, id: \.id) { list in
//                                if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
//                                    let binding = Binding<List>(
//                                        get: { db.lists[index] },
//                                        set: { db.lists[index] = $0 }
//                                    )
//                                    ListView(list: binding, helper: helper, db: db)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 15)
//                    }
//                }
//            }
//            .navigationBarBackButtonHidden()
//            .sheet(isPresented: $showAddListView) {
//                AddListView(helper: helper, lists: $db.lists)
//                    .presentationDetents([.height(500)])
//                    .presentationCornerRadius(25)
//                    .interactiveDismissDisabled()
//            }
//        }
//    }
//}

//struct DashboardView: View {
//    @State var searchText: String = ""
//    @State var showAddListView: Bool = false
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//    @State private var animatePinnedLists = false
//    
//    var filteredLists: [List] {
//        if searchText.isEmpty {
//            return db.lists
//        } else {
//            return db.lists.filter { list in
//                list.listName.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
//    
//    var pinnedLists: [List] {
//        return filteredLists.filter { $0.isPinned }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Custom stylish background
//                LinearGradient(
//                    colors: [
//                        Color(colorScheme == .dark ? .black : .white),
//                        Color(colorScheme == .dark ? .black : .white).opacity(0.9)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .overlay(
//                    ZStack {
//                        ForEach(0..<20) { i in
//                            Circle()
//                                .fill(Color.blue.opacity(0.03))
//                                .frame(width: CGFloat.random(in: 50...200))
//                                .position(
//                                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
//                                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
//                                )
//                        }
//                    }
//                )
//                .ignoresSafeArea()
//                
//                VStack(alignment: .leading, spacing: 8) {
//                    // Modern header with subtle animation
//                    VStack(alignment: .leading, spacing: 4) {
//                        HStack {
//                            Text("Welcome Back")
//                                .font(.title3)
//                                .fontWeight(.medium)
//                                .foregroundStyle(Color.gray)
//                            
//                            Image(systemName: "hand.wave.fill")
//                                .foregroundStyle(Color.yellow)
//                                .font(.title3)
//                        }
//                        
//                        Text("My Tasks")
//                            .font(.system(size: 36, weight: .bold))
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    }
//                    .padding([.horizontal, .top])
//                    
//                    // Pinned section with modern design
//                    if !pinnedLists.isEmpty {
//                        HStack {
//                            Text("Favorites")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundStyle(colorScheme == .dark ? .white : .black)
//                            
//                            Image(systemName: "star.fill")
//                                .foregroundStyle(Color.yellow)
//                                .font(.body)
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 10)
//                        
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 16) {
//                                ForEach(pinnedLists, id: \.id) { list in
//                                    if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
//                                        let binding = Binding<List>(
//                                            get: { db.lists[index] },
//                                            set: { db.lists[index] = $0 }
//                                        )
//                                        PinnedListView(list: binding, helper: helper, db: db)
//                                            .scaleEffect(animatePinnedLists ? 1 : 0.95)
//                                            .opacity(animatePinnedLists ? 1 : 0.7)
//                                            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: animatePinnedLists)
//                                    }
//                                }
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                        }
//                        .onAppear {
//                            animatePinnedLists = true
//                        }
//                    }
//                    
//                    // All lists section with floating add button
//                    HStack {
//                        Text("All Lists")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                        
//                        Spacer()
//                        
//                        Button {
//                            showAddListView = true
//                        } label: {
//                            ZStack {
//                                Circle()
//                                    .fill(LinearGradient(
//                                        colors: [.blue, .purple.opacity(0.8)],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ))
//                                    .frame(width: 38, height: 38)
//                                
//                                Image(systemName: "plus")
//                                    .fontWeight(.semibold)
//                                    .foregroundStyle(.white)
//                                    .font(.system(size: 16))
//                            }
//                            .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 8)
//                    
//                    // Fancy search bar
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundStyle(.gray)
//                        
//                        TextField("Search lists...", text: $searchText)
//                            .font(.system(size: 16))
//                        
//                        if !searchText.isEmpty {
//                            Button(action: {
//                                searchText = ""
//                            }) {
//                                Image(systemName: "xmark.circle.fill")
//                                    .foregroundStyle(.gray)
//                            }
//                        }
//                    }
//                    .padding(12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
//                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
//                    )
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                    
//                    // Modern list view
//                    ScrollView {
//                        VStack(spacing: 12) {
//                            ForEach(filteredLists, id: \.id) { list in
//                                if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
//                                    let binding = Binding<List>(
//                                        get: { db.lists[index] },
//                                        set: { db.lists[index] = $0 }
//                                    )
//                                    ListView(list: binding, helper: helper, db: db)
//                                        .transition(.opacity)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                    }
//                }
//            }
//            .navigationBarBackButtonHidden()
//            .sheet(isPresented: $showAddListView) {
//                AddListView(helper: helper, lists: $db.lists)
//                    .presentationDetents([.height(500)])
//                    .presentationCornerRadius(25)
//                    .interactiveDismissDisabled()
//            }
//        }
//    }
//}

struct DashboardView: View {
    @State var searchText: String = ""
    @State var showAddListView: Bool = false
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @State private var animatePinnedLists = false
    
    var filteredLists: [List] {
        if searchText.isEmpty {
            return db.lists
        } else {
            return db.lists.filter { list in
                list.listName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var pinnedLists: [List] {
        return filteredLists.filter { $0.isPinned }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Custom stylish background with dark mode improvements
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
                        ForEach(0..<20) { i in
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
                    // Modern header with subtle animation
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Welcome Back")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray)
                            
                            Image(systemName: "hand.wave.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.title3)
                        }
                        
                        Text("My Tasks")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .padding([.horizontal, .top])
                    
                    // Pinned section with modern design
                    if !pinnedLists.isEmpty {
                        HStack {
                            Text("Favorites")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.body)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(pinnedLists, id: \.id) { list in
                                    if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
                                        let binding = Binding<List>(
                                            get: { db.lists[index] },
                                            set: { db.lists[index] = $0 }
                                        )
                                        PinnedListView(list: binding, helper: helper, db: db)
                                            .scaleEffect(animatePinnedLists ? 1 : 0.95)
                                            .opacity(animatePinnedLists ? 1 : 0.7)
                                            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: animatePinnedLists)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .onAppear {
                            animatePinnedLists = true
                        }
                    }
                    
                    // All lists section with floating add button
                    HStack {
                        Text("All Lists")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                        
                        Button {
                            showAddListView = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.blue, colorScheme == .dark ? .purple.opacity(0.9) : .purple.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 38, height: 38)
                                
                                Image(systemName: "plus")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                            }
                            .shadow(color: colorScheme == .dark ? .blue.opacity(0.5) : .blue.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Fancy search bar with dark mode improvements
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.8) : .gray)
                        
                        TextField("Search lists...", text: $searchText)
                            .font(.system(size: 16))
                            .foregroundStyle(colorScheme == .dark ? .white : .primary)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.8) : .gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white)
                            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Modern list view
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredLists, id: \.id) { list in
                                if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
                                    let binding = Binding<List>(
                                        get: { db.lists[index] },
                                        set: { db.lists[index] = $0 }
                                    )
                                    ListView(list: binding, helper: helper, db: db)
                                        .transition(.opacity)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showAddListView) {
                AddListView(helper: helper, lists: $db.lists)
                    .presentationDetents([.height(500)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            }
        }
    }
}

//struct DashboardView: View {
//    @State var searchText: String = ""
//    @State var showAddListView: Bool = false
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//
//    var filteredLists: [List] {
//        if searchText.isEmpty {
//            return db.lists
//        } else {
//            return db.lists.filter {
//                $0.listName.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppConstants.background(for: colorScheme)
//                    .ignoresSafeArea()
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        
//                        // MARK: - Welcome Header
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text("Welcome Back 👋")
//                                .font(.title3)
//                                .foregroundStyle(.secondary)
//                            
//                            Text("Explore Your Lists")
//                                .font(.largeTitle)
//                                .fontWeight(.bold)
//                        }
//                        .padding(.horizontal)
//                        .padding(.top)
//
//                        // MARK: - Pinned Lists Section
//                        if !filteredLists.filter({ $0.isPinned }).isEmpty {
//                            Text("Pinned Lists")
//                                .font(.title2)
//                                .fontWeight(.semibold)
//                                .padding(.horizontal)
//
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 15) {
//                                    ForEach(filteredLists.filter { $0.isPinned }, id: \.id) { list in
//                                        if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
//                                            let binding = Binding<List>(
//                                                get: { db.lists[index] },
//                                                set: { db.lists[index] = $0 }
//                                            )
//                                            PinnedListView(list: binding, helper: helper, db: db)
//                                        }
//                                    }
//                                }
//                                .padding(.horizontal)
//                            }
//                        }
//
//                        // MARK: - Search + Add
//                        HStack {
//                            Text("Your Lists")
//                                .font(.title2)
//                                .fontWeight(.semibold)
//                            
//                            Spacer()
//
//                            Button {
//                                showAddListView = true
//                            } label: {
//                                Image(systemName: "plus.circle.fill")
//                                    .font(.title2)
//                                    .foregroundStyle(Color.accentColor)
//                            }
//                        }
//                        .padding(.horizontal)
//
//                        CustomSearchBar(text: $searchText, prompt: "Search List...")
//                            .padding(.horizontal)
//
//                        // MARK: - Main Lists
//                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 15)], spacing: 15) {
//                            ForEach(filteredLists, id: \.id) { list in
//                                if let index = db.lists.firstIndex(where: { $0.id == list.id }) {
//                                    let binding = Binding<List>(
//                                        get: { db.lists[index] },
//                                        set: { db.lists[index] = $0 }
//                                    )
//                                    ListView(list: binding, helper: helper, db: db)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 40)
//                    }
//                }
//            }
//            .navigationBarBackButtonHidden()
//            .sheet(isPresented: $showAddListView) {
//                AddListView(helper: helper, lists: $db.lists)
//                    .presentationDetents([.height(500)])
//                    .presentationCornerRadius(25)
//                    .interactiveDismissDisabled()
//            }
//        }
//    }
//}

#Preview {
    DashboardView(helper: Helper(), db: Supabase())
}
