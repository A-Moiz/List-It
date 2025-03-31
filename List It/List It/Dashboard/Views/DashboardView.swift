//
//  DashboardView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

//struct DashboardView: View {
//    @State var searchText: String = ""
//    let columns = [
//        GridItem(.flexible(), spacing: 5),
//        GridItem(.flexible(), spacing: 5)
//    ]
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "fe8151")
//                    .ignoresSafeArea()
//
//                VStack {
//                    Text("Hello!")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding()
//                        .font(.system(size: 32, weight: .bold, design: .default))
//
//                    CustomSearchBar(text: $searchText, prompt: "Search Collection...")
//
//                    Text("Your Collections")
//                        .font(.title2)
//                        .bold()
//                        .padding(.top)
//
//                    Divider()
//
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 10) {
//                            ForEach(0..<10, id: \.self) { _ in
//                                CollectionView()
//                            }
//                        }
//                        .padding(.vertical, 10)
//                    }
//                    .padding(.horizontal, 10)
//                }
//            }
//        }
//    }
//}

//struct DashboardView: View {
//    @State var searchText: String = ""
//    let columns = [
//        GridItem(.flexible(), spacing: 12),
//        GridItem(.flexible(), spacing: 12)
//    ]
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Background with gradient for a fresh look
//                LinearGradient(gradient: Gradient(colors: [Color(hex: "FF8C61"), Color(hex: "FF6363")]),
//                               startPoint: .topLeading,
//                               endPoint: .bottomTrailing)
//                    .ignoresSafeArea()
//
//                VStack(alignment: .leading, spacing: 0) {
//                    // Top Greeting Section
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Welcome Back 👋")
//                            .font(.title3)
//                            .fontWeight(.medium)
//                            .foregroundColor(.white.opacity(0.8))
//
//                        Text("Explore Your Collections")
//                            .font(.largeTitle)
//                            .bold()
//                            .foregroundColor(.white)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 60)
//
//                    // Search Bar
//                    CustomSearchBar(text: $searchText, prompt: "Search Collection...")
//                        .padding(.horizontal, 20)
//                        .padding(.top, 10)
//
//                    // Collections Header
//                    HStack {
//                        Text("Your Collections")
//                            .font(.title2)
//                            .bold()
//                            .foregroundColor(.white)
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            // Add new collection action
//                        }) {
//                            Image(systemName: "plus")
//                                .font(.title2)
//                                .foregroundColor(.white)
//                                .padding(10)
//                                .background(Color.white.opacity(0.2))
//                                .clipShape(Circle())
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 15)
//
//                    // Frosted Glass Collection Grid
//                    ScrollView {
//                        VStack {
//                            LazyVGrid(columns: columns, spacing: 12) {
//                                ForEach(0..<10, id: \.self) { _ in
//                                    CollectionView()
//                                }
//                            }
//                            .padding(15)
//                        }
//                        .background(.ultraThinMaterial) // Frosted Glass Effect
//                        .clipShape(RoundedRectangle(cornerRadius: 25))
//                        .padding(.horizontal, 20)
//                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
//                    }
//                    .padding(.top, 10)
//                }
//            }
//        }
//    }
//}

struct DashboardView: View {
    @State var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(gradient: Gradient(colors: [Color(hex: "fe8151"), Color(hex: "ff9b73")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 10) {
                    // Greeting text
                    Text("Hello!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    CustomSearchBar(text: $searchText, prompt: "Search Collection...")
                        .padding(.horizontal)

                    // Collections Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Collections")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Divider()
                            .background(Color.white.opacity(0.7))
                    }
                    .padding(.horizontal)

                    // Collection List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(0..<10, id: \.self) { _ in
                                CollectionView()
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
