//
//  PinnedListView.swift
//  List It
//
//  Created by Abdul Moiz on 17/04/2025.
//

import SwiftUI

//struct PinnedListView: View {
//    @Binding var list: List
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(list.bgColor)
//                    .frame(width: 100, height: 120)
//                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
//                
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            list.isPinned.toggle()
//                        }) {
//                            Image(systemName: list.isPinned ? "star.fill" : "star")
//                                .foregroundStyle(.black)
//                                .font(.system(size: 15))
//                        }
//                        .buttonStyle(.plain)
//                        .padding(4)
//                    }
//
//                    Spacer()
//
//                    VStack(spacing: 10) {
//                        if list.isDefault {
//                            Image(systemName: list.listIcon)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30)
//                                .foregroundStyle(.black)
//                        } else {
//                            Image(systemName: "checklist")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30)
//                                .foregroundStyle(.black)
//                        }
//
//                        Text(list.listName.capitalized)
//                            .font(.system(size: 14))
//                            .multilineTextAlignment(.center)
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    }
//
//                    Spacer()
//                }
//                .frame(width: 90, height: 120)
//            }
//        }
//        .buttonStyle(.plain)
//    }
//}

struct PinnedListView: View {
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
            ZStack {
                // Hexagonal inspired shape
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [list.bgColor, list.bgColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: list.bgColor.opacity(0.5), radius: 6, x: 0, y: 3)
                
                VStack(spacing: 0) {
                    // Improved pin button design
                    HStack {
                        Spacer()
                        Button(action: {
                            list.isPinned.toggle()
                        }) {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: list.isPinned ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                    
                    Spacer()
                    
                    // Cool circle background for icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 52, height: 52)
                        
                        if list.isDefault {
                            Image(systemName: list.listIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "checklist")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // Improved text legibility
                    Text(list.listName.capitalized)
                        .font(.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                    
                    Spacer()
                }
                .frame(width: 110, height: 140)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), collections: [], isPinned: false)
    PinnedListView(list: $list, helper: Helper(), db: Supabase())
}
