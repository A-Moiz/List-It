//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct ListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @State private var localIsPinned: Bool = false
    @State private var isUpdating: Bool = false
    
    var body: some View {
        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
            ZStack(alignment: .topTrailing) {
                // MARK: - List background
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(list.bgColor, lineWidth: 1.5)
                    )
                    .frame(height: 120)
                    .shadow(color: list.bgColor.opacity(colorScheme == .dark ? 0.5 : 0.3), radius: 3, x: 0, y: 2)
                
                VStack(spacing: 8) {
                    // MARK: - List icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [list.bgColor, list.bgColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: list.isDefault ? list.listIcon : "checklist")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 12)
                    
                    // MARK: - List title and info
                    VStack(alignment: .center, spacing: 10) {
                        Text(list.listName.description.capitalized)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                        
                        //MARK: - Task/Note count
                        let taskCount = db.userTasks.filter { $0.listID == list.id && !$0.isDeleted && !$0.isCompleted }.count
                        let noteCount = db.userNotes.filter { $0.listID == list.id && !$0.isDeleted }.count
                        
                        if !list.isDefault {
                            Text("\(taskCount) \(taskCount == 1 ? "Task" : "Tasks") • \(noteCount) \(noteCount == 1 ? "Note" : "Notes")")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .padding(.horizontal, 3)
                .frame(maxWidth: .infinity)
                
                // MARK: - Side accent
                VStack {
                    Rectangle()
                        .fill(list.bgColor)
                        .frame(width: 4)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contextMenu {
                if list.isDefault {
                    Label("Cannot delete default List", systemImage: "lock")
                        .foregroundStyle(.secondary)
                } else {
                    Button(role: .destructive) {
                        withAnimation {
                            db.deleteList(list: list) { success, error in
                                if !success {
                                    helper.showAlertWithMessage("Error deleting List: \(error ?? "Unknown error")")
                                } else {
                                    db.fetchUserLists { success, errorMessage in
                                        if !success, let error = errorMessage {
                                            helper.showAlertWithMessage("Error fetching user Lists: \(error)")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Delete List", systemImage: "trash")
                    }
                }
                
                if list.isDefault {
                    Label("Cannot pin default List", systemImage: "pin.slash")
                        .foregroundStyle(.secondary)
                } else {
                    Button {
                        withAnimation {
                            if list.isDefault {
                                localIsPinned.toggle()
                                self.list.isPinned.toggle()
                            } else {
                                let newPinStatus = !localIsPinned
                                localIsPinned = newPinStatus
                                
                                db.updatePinStatus(list: list, isPinned: newPinStatus) { success, error in
                                    if !success {
                                        helper.showAlertWithMessage("Error updating List: \(error)")
                                    }
                                }
                                self.list.isPinned = newPinStatus
                                
                                db.fetchUserLists { success, errorMessage in
                                    if !success, let error = errorMessage {
                                        localIsPinned = !newPinStatus
                                        self.list.isPinned = !newPinStatus
                                        helper.showAlertWithMessage("Error updating List: \(error)")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(localIsPinned ? "Unpin List" : "Pin List", systemImage: localIsPinned ? "pin.fill" : "pin")
                    }
                }
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            localIsPinned = list.isPinned
        }
        .onChange(of: list.isPinned) { newValue in
            localIsPinned = newValue
        }
        .id(list.id)
    }
}

//#Preview {
//    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: false, bgColorHex: "#87CEEB", userId: "", isPinned: false)
//    ListView(list: $list, helper: Helper(), db: Supabase())
//}
