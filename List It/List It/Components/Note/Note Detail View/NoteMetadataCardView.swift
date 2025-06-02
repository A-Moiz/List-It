//
//  NoteMetadataCardView.swift
//  List It
//
//  Created by Abdul Moiz on 01/06/2025.
//

import SwiftUI

struct NoteMetadataCardView: View {
    // MARK: - Properties
    @Binding var note: Note
    @Binding var selectedColorHex: String
    @Binding var collection: Collection
    @Binding var animateContent: Bool
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Note Information")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    MetaDataRow(title: "Created", value: db.formattedDate(note.createdAt))
                    MetaDataRow(title: "Collection", value: collection.collectionName)
                    HStack {
                        MetaDataRow(title: "Pinned", value: note.isPinned ? "Yes" : "No")
                        Spacer()
                        // MARK: - Pin toggle
                        Button {
                            withAnimation {
                                let newPinStatus = !note.isPinned
                                db.updateNotePinStatus(note: note, isPinned: newPinStatus) { success, error in
                                    if !success {
                                        helper.showAlertWithMessage("Error updating Note: \(error ?? "Unknown error")")
                                    }
                                }
                                note.isPinned = newPinStatus
                            }
                        } label: {
                            HStack {
                                Image(systemName: "pin.fill")
                                    .foregroundColor(Color(hex: selectedColorHex))
                                Text(note.isPinned ? "Unpin this Note" : "Pin this Note")
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color(hex: selectedColorHex).opacity(0.5), lineWidth: 1.5)
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(hex: selectedColorHex).opacity(0.5), lineWidth: 1.5)
        )
    }
}
