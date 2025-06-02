//
//  NoteView.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import SwiftUI

struct NoteView: View {
    // MARK: - Properties
    @Binding var note: Note
    @Binding var collection: Collection
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetailView: Bool = false

    private var priorityColor: Color {
        note.isPinned ? .yellow : .clear
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            noteBackground
            noteContent
        }
        .onTapGesture {
            showDetailView = true
        }
        .sheet(isPresented: $showDetailView) {
            NoteDetailView(note: $note, collection: $collection, db: db, helper: helper)
                .presentationDetents([.height(800)])
                .presentationCornerRadius(10)
                .interactiveDismissDisabled()
        }
        .contextMenu { contextMenuContent }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor, lineWidth: priorityColor == .clear ? 0 : 2)
        )
    }

    // MARK: - Supporting views
    private var noteBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(note.bgColor.opacity(colorScheme == .dark ? 0.4 : 0.8))
            .frame(width: 120, height: 100)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var noteContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
            Text(note.title)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 10)
                .padding(.bottom, (note.description?.isEmpty ?? true) ? 8 : 0)

            if let description = note.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
            }
        }
        .frame(width: 120, height: 100, alignment: .bottomLeading)
    }

    // MARK: - Context menu
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let newPinStatus = !note.isPinned
                db.updateNotePinStatus(note: note, isPinned: newPinStatus) { success, error in
                    if !success {
                        helper.showAlertWithMessage("Error pinning Note: \(error ?? "Unknown error")")
                    }
                }
                note.isPinned = newPinStatus
            }
        } label: {
            Label(note.isPinned ? "Unpin Note" : "Pin Note", systemImage: note.isPinned ? "pin.fill" : "pin")
        }

        Menu {
            ForEach(db.collections.filter { $0.listID == list.id }) { collection in
                Button(action: {
                    withAnimation {
                        db.moveNote(note: note, newCollectionID: collection.id) { success, error in
                            if !success {
                                helper.showAlertWithMessage("Error moving Note to new Collection: \(error ?? "Unknown error")")
                            } else {
                                db.fetchUserNotes { success, errorMessage in
                                    if !success, let error = errorMessage {
                                        helper.showAlertWithMessage("Error fetching and displaying new Note: \(error)")
                                    }
                                }
                            }
                        }
                    }
                }) {
                    Text(collection.collectionName)
                }
            }
        } label: {
            Label("Move Note", systemImage: "folder")
        }
        
        Button(role: .destructive) {
            db.deleteNote(note: note) { success, error in
                if !success {
                    helper.showAlertWithMessage("Error deleting Note: \(error ?? "Unknown error")")
                } else {
                    db.fetchUserNotes { success, errorMessage in
                        if !success, let error = errorMessage {
                            helper.showAlertWithMessage("Error fetching and displaying Notes: \(error)")
                        }
                    }
                }
            }
        } label: {
            Label("Delete Note", systemImage: "trash")
        }
    }
}

//#Preview {
//    @Previewable @State var note = Note(id: UUID().uuidString, title: "Testing", description: "Testing note component", dateCreated: Date(), isDeleted: false, bgColorHex: "#87CEEB", isPinned: false)
//    let sampleTasks = [
//        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
//        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
//        ToDoTask(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
//        ToDoTask(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
//    ]
//
//    let sampleNotes = [
//        Note(id: UUID().uuidString, title: "Watering", description: "Don't forget to water the plants.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false)
//    ]
//    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: sampleTasks, notes: sampleNotes)
//    NoteView(note: $note, collection: $collection, helper: Helper(), db: Supabase())
//}
