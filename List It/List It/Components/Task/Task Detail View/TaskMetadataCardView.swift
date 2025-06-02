//
//  TaskMetadataCardView.swift
//  List It
//
//  Created by Abdul Moiz on 04/05/2025.
//

import SwiftUI

struct TaskMetadataCardView: View {
    // MARK: - Properties
    @Binding var task: ToDoTask
    @Binding var collection: Collection
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: - Title text
            Text("METADATA")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                .padding(.horizontal, 4)

            VStack(spacing: 16) {
                // MARK: - Task created date
                HStack {
                    Label {
                        Text("Created")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(collection.bgColor)
                    }

                    Spacer()
                    
                    Text(db.formattedDate(task.createdAt))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                // MARK: - Task Collection
                HStack {
                    Label {
                        Text("Collection")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "folder")
                            .foregroundColor(collection.bgColor)
                    }

                    Spacer()

                    Text(collection.collectionName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
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
    }
}

//#Preview {
//    TaskMetadataCardView()
//}
