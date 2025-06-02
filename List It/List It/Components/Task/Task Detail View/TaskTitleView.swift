//
//  TaskTitleView.swift
//  List It
//
//  Created by Abdul Moiz on 04/05/2025.
//

import SwiftUI

struct TaskTitleView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @Binding var editedText: String
    @Binding var collection: Collection
    @Binding var animateContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Title text
            Text("TASK TITLE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                .padding(.horizontal, 4)
            
            // MARK: - Title textfield
            TextField("Task title...", text: $editedText)
                .font(.title3.bold())
                .foregroundStyle(Color.primary)
                .padding()
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
//    @Previewable @State var editedText = ""
//    @Previewable @State var animateContent: Bool = false
//    var sampleCollection = Collection(id: "", collectionName: "", bgColorHex: "", dateCreated: Date())
//    TaskTitleView(editedText: $editedText, collection: .constant(sampleCollection), animateContent: $animateContent)
//}
