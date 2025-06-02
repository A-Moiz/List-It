//
//  NoteListView.swift
//  List It
//
//  Created by Abdul Moiz on 02/05/2025.
//

import SwiftUI

struct NoteListView: View {
    // MARK: - Properties
    @Binding var collection: Collection
    @Binding var list: List
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    let collectionColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                let filteredNotes = db.userNotes.filter{ $0.collectionID == collection.id }
                let sortedNotes = filteredNotes.sorted {
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned && !$1.isPinned
                    } else {
                        return $0.createdAt > $1.createdAt
                    }
                }
                
                if sortedNotes.isEmpty {
                    EmptyStateView(icon: "note.text", collectionColor: collectionColor, message: "No notes in this Collection", subMessage: "Add a Note to get started.")
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(
                            db.userNotes.indices
                                .filter { db.userNotes[$0].collectionID == collection.id }
                                .sorted(by: { sortFunc(db.userNotes[$0], db.userNotes[$1]) }),
                            id: \.self
                        ) { index in
                            NoteView(
                                note: $db.userNotes[index],
                                collection: $collection,
                                list: $list,
                                helper: helper,
                                db: db
                            )
                            .aspectRatio(contentMode: .fill)
                            .frame(minHeight: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ?
                                          Color(UIColor.systemGray6) :
                                            Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .padding(.top, 8)
        }
    }
    
    func sortFunc(_ a: Note, _ b: Note) -> Bool {
        if a.isPinned != b.isPinned {
            return a.isPinned && !b.isPinned
        } else {
            return a.createdAt > b.createdAt
        }
    }
}

//#Preview {
//    let sampleNote = Note(id: "", title: "", description: "", dateCreated: Date(), isDeleted: false, bgColorHex: "", isPinned: false)
//
//    let sampleCollection = Collection(id: "", collectionName: "", bgColorHex: "", dateCreated: Date())
//
//    let sampleList = List(id: "", listIcon: "", listName: "", isDefault: false, bgColorHex: "", userId: "", isPinned: false)
//
//    NoteListView(
//        sortedNotes: sampleCollection.notes,
//        collection: .constant(sampleCollection),
//        list: .constant(sampleList),
//        db: Supabase(),
//        helper: Helper(),
//        collectionColor: .blue
//    )
//}
