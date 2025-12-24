//
//  PinnedListView.swift
//  List It
//
//  Created by Abdul Moiz on 17/04/2025.
//

import SwiftUI

//struct PinnedListView: View {
//    // MARK: - Properties
//    @Binding var list: List
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        // MARK: - Tapping goes to list detail view
//        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
//            ZStack {
//                CardBackground(list: $list)
//                VStack {
//                    IconSection(list: $list)
//                    Spacer()
//                    StatsSection(helper: helper, db: db, list: $list)
//                }
//                .frame(width: 140, height: 180)
//            }
//            .contextMenu {
//                if list.isDefault {
//                    Label("Cannot delete default List", systemImage: "lock")
//                        .foregroundColor(.secondary)
//                } else {
//                    Button(role: .destructive) {
//                        withAnimation {
//                            db.deleteList(list: list) { success, error in
//                                if !success {
//                                    helper.showAlertWithMessage("Error deleting List: \(error ?? "Unknown error")")
//                                } else {
//                                    db.fetchUserLists { success, errorMessage in
//                                        if !success, let error = errorMessage {
//                                            helper.showAlertWithMessage("Error fetching user Lists: \(error)")
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    } label: {
//                        Label("Delete List", systemImage: "trash")
//                    }
//                }
//                
//                Button {
//                    withAnimation {
//                        db.updatePinStatus(list: list, isPinned: false) { success, error in
//                            if !success {
//                                helper.showAlertWithMessage("Error unpinning List: \(error ?? "Unknown error")")
//                            } else {
//                                self.list.isPinned = false
//                                
//                                db.fetchUserLists { success, errorMessage in
//                                    if !success, let error = errorMessage {
//                                        helper.showAlertWithMessage("Error updating List: \(error)")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                } label: {
//                    Label("Unpin List", systemImage: "pin.fill")
//                }
//            }
//            .alert(isPresented: $helper.showAlert) {
//                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
//            }
//            .scaleEffect(1.0)
//            .rotation3DEffect(
//                .degrees(0),
//                axis: (x: 1, y: 0, z: 0),
//                perspective: 1.0
//            )
//        }
//    }
//}

struct PinnedListView: View {
    // MARK: - Properties
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
            ZStack {
                CardBackground(list: $list)

                VStack {
                    IconSection(list: $list)
                        .scaleEffect(0.85)
                        .padding(.top, 2)

                    StatsSection(helper: helper, db: db, list: $list)
                        .scaleEffect(0.85)
                        .padding(.bottom)
                    
                    Spacer()
                }
            }
            .frame(width: 100, height: 110)
            .scaleEffect(0.9)
            .clipped()
            .cornerRadius(12)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .contextMenu {
                if list.isDefault {
                    Label("Cannot delete default List", systemImage: "lock")
                        .foregroundColor(.secondary)
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

                Button {
                    withAnimation {
                        db.updatePinStatus(list: list, isPinned: false) { success, error in
                            if !success {
                                helper.showAlertWithMessage("Error unpinning List: \(error ?? "Unknown error")")
                            } else {
                                self.list.isPinned = false
                                db.fetchUserLists { success, errorMessage in
                                    if !success, let error = errorMessage {
                                        helper.showAlertWithMessage("Error updating List: \(error)")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Label("Unpin List", systemImage: "pin.fill")
                }
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(helper.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var sampleList = List(id: "", createdAt: Date(), listIcon: "", listName: "OPBR", isDefault: false, bgColorHex: "", userId: "", isPinned: true)
    PinnedListView(list: $sampleList, helper: Helper(), db: Supabase())
}
