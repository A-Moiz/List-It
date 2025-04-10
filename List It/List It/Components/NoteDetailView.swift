//
//  NoteView.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import SwiftUI

//struct NoteDetailView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.dismiss) var dismiss
//    @Binding var note: Note
//    @Binding var collection: Collection
//    @State var selectedColorHex: String = ""
//    @State private var isNavigating = false
//    @ObservedObject var db: Supabase
//    @ObservedObject var helper: Helper
//
//    @State private var editedTitle: String = ""
//    @State private var editedDescription: String = ""
//
//    private static var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }()
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppConstants.background(for: colorScheme)
//                    .ignoresSafeArea()
//
//                VStack {
//                    TextField("Enter title", text: $editedTitle)
//                        .font(.title)
//                        .foregroundColor(colorScheme == .dark ? .white : .black)
//                        .underline()
//                        .multilineTextAlignment(.center)
//
//                    TransparentTextEditor(text: $editedDescription)
//                        .frame(minHeight: 200)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.4), lineWidth: 1)
//                        )
//                        .padding(8)
//
//                    Spacer()
//                    
//                    Divider()
//                    
//                    Text("Note color:")
//                        .foregroundStyle(.gray)
//
//                    ColorSelectionView(colorHexes: AppConstants.listColorHexes, selectedHex: $selectedColorHex)
//                }
//                .padding()
//            }
//            .navigationTitle("Date Created: \(Self.dateFormatter.string(from: note.dateCreated))")
//            .toolbarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        withAnimation {
//                            note.title = editedTitle
//                            note.description = editedDescription
//                            note.bgColorHex = selectedColorHex.isEmpty ? note.bgColorHex : selectedColorHex
//                        }
//                        dismiss()
//                    }) {
//                        Text("Save")
//                            .foregroundColor(colorScheme == .dark ? .white : .black)
//                            .fontWeight(.bold)
//                    }
//                }
//            }
//            .onAppear {
//                editedTitle = note.title
//                editedDescription = note.description
//                selectedColorHex = note.bgColorHex
//            }
//        }
//    }
//}

struct NoteDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var note: Note
    @Binding var collection: Collection
    @State var selectedColorHex: String = ""
    @State private var isNavigating = false
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper

    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Enter title...", text: $editedTitle)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                        )
                        .multilineTextAlignment(.center)

                    TransparentTextEditor(text: $editedDescription)
                        .padding(12)
                        .frame(minHeight: 200)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                        )

                    Spacer()

                    Divider()

                    VStack(spacing: 8) {
                        Text("Note Color")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        ColorSelectionView(colorHexes: AppConstants.listColorHexes, selectedHex: $selectedColorHex)
                    }
                    .padding(.bottom, 10)
                }
                .padding()
            }
            .navigationTitle("Created: \(Self.dateFormatter.string(from: note.dateCreated))")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        withAnimation {
                            note.title = editedTitle
                            note.description = editedDescription
                            note.bgColorHex = selectedColorHex.isEmpty ? note.bgColorHex : selectedColorHex
                        }
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.accentColor)
                }
            }
            .onAppear {
                editedTitle = note.title
                editedDescription = note.description
                selectedColorHex = note.bgColorHex
            }
        }
    }
}

#Preview {
    @Previewable @State var note = Note(id: UUID().uuidString, title: "Testing", description: "Testing note component", dateCreated: Date(), isDeleted: false, bgColorHex: "#87CEEB", isPinned: false)
    @Previewable @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: [])
    NoteDetailView(note: $note, collection: $collection, db: Supabase(), helper: Helper())
}
