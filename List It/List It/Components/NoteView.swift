//
//  NoteView.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import SwiftUI

//struct NoteView: View {
//    @Binding var note: Note
//    @Binding var collection: Collection
//    @ObservedObject var helper: Helper
//    @ObservedObject var db: Supabase
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        NavigationLink {
//            NoteDetailView(note: $note, collection: $collection, db: db, helper: helper)
//        } label: {
//            ZStack {
//                Rectangle()
//                    .fill(note.bgColor)
//                    .ignoresSafeArea()
//                    .frame(width: 150, height: 100)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                Text(note.title)
//                    .font(.system(size: 14))
//                    .bold()
//                    .lineLimit(1)
//                    .frame(maxWidth: 100, alignment: .center)
//
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button {
//                            note.isPinned.toggle()
//                        } label: {
//                            Image(systemName: note.isPinned ? "pin.fill" : "pin")
//                                .padding(8)
//                        }
//                        .background(Color.clear)
//                        .contentShape(Rectangle())
//                        .allowsHitTesting(true)
//                    }
//                    Spacer()
//                }
//                .frame(width: 150, height: 100)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}

struct NoteView: View {
    @Binding var note: Note
    @Binding var collection: Collection
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink {
            NoteDetailView(note: $note, collection: $collection, db: db, helper: helper)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(note.bgColor.opacity(colorScheme == .dark ? 0.4 : 0.8))
                    .frame(width: 160, height: 120)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    Text(note.title)
                        .font(.headline)
                        .bold()
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 8)
                }
                .frame(width: 160, height: 120, alignment: .bottomLeading)

                Button {
                    note.isPinned.toggle()
                } label: {
                    Image(systemName: note.isPinned ? "pin.fill" : "pin")
                        .padding(8)
                        .foregroundColor(.primary)
                }
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(8)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var note = Note(id: UUID().uuidString, title: "Testing", description: "Testing note component", dateCreated: Date(), isDeleted: false, bgColorHex: "#87CEEB", isPinned: false)
    let sampleTasks = [
        Task(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
    ]
    
    let sampleNotes = [
        Note(id: UUID().uuidString, title: "Watering", description: "Don't forget to water the plants.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false)
    ]
    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: sampleTasks, notes: sampleNotes)
    NoteView(note: $note, collection: $collection, helper: Helper(), db: Supabase())
}
