//
//  TaskDescriptionView.swift
//  List It
//
//  Created by Abdul Moiz on 04/05/2025.
//

import SwiftUI

struct TaskDescriptionView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @Binding var editedDescription: String
    @Binding var collection: Collection
    @Binding var animateContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Title text
            Text("DESCRIPTION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                .padding(.horizontal, 4)
            
            // MARK: - Custom text editor
            TransparentTextEditor(text: $editedDescription)
                .placeholder(when: editedDescription.isEmpty) {
                    Text("Add notes, details, or additional context...")
                        .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray.opacity(0.8))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                .padding(12)
                .frame(minHeight: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(collection.bgColor.opacity(0.3), lineWidth: 1)
                )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}

//#Preview {
//    @Previewable @State var editedDescription = ""
//    @Previewable @State var animateContent: Bool = false
//    var sampleCollection = Collection(id: "", collectionName: "", bgColorHex: "", dateCreated: Date())
//    TaskDescriptionView(editedDescription: $editedDescription, collection: .constant(sampleCollection), animateContent: $animateContent)
//}
