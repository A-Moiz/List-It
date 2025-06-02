//
//  CompletedTaskContent.swift
//  List It
//
//  Created by Abdul Moiz on 24/05/2025.
//

import SwiftUI

struct CompletedTaskContent: View {
    // MARK: - Properties
    let task: ToDoTask
    let dateFormatter: DateFormatter
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Main task content with due date status
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.text)
                        .font(.body.weight(.medium))
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .lineLimit(nil)
                    
                    if let desc = task.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
                
                // MARK: - Due date completion status
                if let dueDate = task.dueDate, let completedDate = task.dateCompleted {
                    DueDateStatusView(dueDate: dueDate, completedDate: completedDate)
                }
            }
            
            // MARK: - Metadata section
            VStack(alignment: .leading, spacing: 8) {
                // Collection and List info
                HStack(spacing: 12) {
                    Label(listName, systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Label(collectionName, systemImage: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // MARK: - Creation date
                Label(
                    "Created " + dateFormatter.string(from: task.createdAt),
                    systemImage: "calendar"
                )
                .font(.caption2)
                .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    colorScheme == .dark
                    ? Color(.secondarySystemBackground)
                    : Color.white
                )
                .shadow(
                    color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.3),
                            Color.green.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var collectionName: String {
        if let collection = db.collections.first(where: { $0.id == task.collectionID }) {
            return collection.collectionName
        }
        return "Unknown Collection"
    }
    
    private var listName: String {
        if let list = db.lists.first(where: { $0.id == task.listID }) {
            return list.listName
        }
        return "Unknown List"
    }
}

//#Preview {
//    CompletedTaskContent()
//}
