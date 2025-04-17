//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

//struct ListView: View {
//    @Binding var list: List
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(list.bgColor)
//                    .frame(height: 90)
//                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
//                
//                HStack(spacing: 15) {
//                    ZStack {
//                        Circle()
//                            .fill(list.bgColor)
//                            .frame(width: 50, height: 50)
//                            .shadow(radius: 3)
//
//                        Image(systemName: list.isDefault ? list.listIcon : "checklist")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24, height: 24)
//                            .foregroundStyle(.black)
//                    }
//                    
//                    Text(list.listName.description.capitalized)
//                        .font(.system(size: 16))
//                        .bold()
//                        .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        list.isPinned.toggle()
//                    }) {
//                        Image(systemName: list.isPinned ? "star.fill" : "star")
//                            .font(.system(size: 20))
//                            .foregroundStyle(list.isPinned ? .yellow : .black)
//                            .padding(10)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(Color.black.opacity(0.2))
//                            )
//                    }
//                    .buttonStyle(.plain)
//                }
//                .padding()
//            }
//            .buttonStyle(PlainButtonStyle())
//        }
//    }
//}

//struct ListView: View {
//    @Binding var list: List
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
//            ZStack {
//                // Modern card design with different shape
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.white.opacity(0.9))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(list.bgColor, lineWidth: 2)
//                    )
//                    .frame(height: 80)
//                    .shadow(color: list.bgColor.opacity(0.3), radius: 4, x: 0, y: 3)
//                
//                HStack(spacing: 16) {
//                    // Left accent bar
//                    Rectangle()
//                        .fill(list.bgColor)
//                        .frame(width: 6)
//                        .padding(.vertical, 15)
//                    
//                    // Icon with gradient background
//                    ZStack {
//                        Circle()
//                            .fill(
//                                LinearGradient(
//                                    colors: [list.bgColor, list.bgColor.opacity(0.7)],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .frame(width: 46, height: 46)
//                        
//                        Image(systemName: list.isDefault ? list.listIcon : "checklist")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 22, height: 22)
//                            .foregroundStyle(.white)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(list.listName.description.capitalized)
//                            .font(.system(size: 17, weight: .semibold))
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                        
//                        // Add subtle task count indicator
//                        Text("\(Int.random(in: 1...10)) tasks")
//                            .font(.system(size: 12))
//                            .foregroundStyle(.gray)
//                    }
//                    
//                    Spacer()
//                    
//                    // Redesigned pin button
//                    Button(action: {
//                        list.isPinned.toggle()
//                    }) {
//                        Image(systemName: list.isPinned ? "pin.fill" : "pin")
//                            .font(.system(size: 18))
//                            .foregroundStyle(list.isPinned ? list.bgColor : .gray)
//                            .frame(width: 36, height: 36)
//                            .background(
//                                Circle()
//                                    .fill(Color.gray.opacity(0.1))
//                            )
//                    }
//                    .buttonStyle(.plain)
//                    .padding(.trailing, 8)
//                }
//                .padding(.horizontal, 4)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}

struct ListView: View {
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
            ZStack {
                // Modern card with dynamic background based on color scheme
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(list.bgColor, lineWidth: 2)
                    )
                    .frame(height: 80)
                    .shadow(color: list.bgColor.opacity(colorScheme == .dark ? 0.5 : 0.3), radius: 4, x: 0, y: 3)
                
                HStack(spacing: 16) {
                    // Left accent bar
                    Rectangle()
                        .fill(list.bgColor)
                        .frame(width: 6)
                        .padding(.vertical, 15)
                    
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [list.bgColor, list.bgColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: list.isDefault ? list.listIcon : "checklist")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(.white)
                    }
                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(list.listName.description.capitalized)
//                            .font(.system(size: 17, weight: .semibold))
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                        
//                        // Add subtle task count indicator with dark mode appropriate color
//                        Text("\(Int.random(in: 1...10)) tasks")
//                            .font(.system(size: 12))
//                            .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
//                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(list.listName.description.capitalized)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        // Calculate and display actual task and note counts
                        let taskCount = list.collections.reduce(0) { $0 + $1.tasks.count }
                        let noteCount = list.collections.reduce(0) { $0 + $1.notes.count }
                        
                        if taskCount > 0 || noteCount > 0 {
                            Text("\(taskCount) task\(taskCount == 1 ? "" : "s")\(noteCount > 0 ? ", \(noteCount) note\(noteCount == 1 ? "" : "s")" : "")")
                                .font(.system(size: 12))
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
                        } else {
                            Text("No items")
                                .font(.system(size: 12))
                                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Redesigned pin button with dark mode appropriate background
                    Button(action: {
                        list.isPinned.toggle()
                    }) {
                        Image(systemName: list.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 18))
                            .foregroundStyle(list.isPinned ? list.bgColor : (colorScheme == .dark ? Color.gray.opacity(0.8) : .gray))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), type: .regular, collections: [], isPinned: false)
    ListView(list: $list, helper: Helper(), db: Supabase())
}
