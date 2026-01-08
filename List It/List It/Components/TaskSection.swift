//
//  TaskSection.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct TaskSection: View {
    let group: (list: List, tasks: [ToDoTask])
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(group.list.bgColor)
                Text(group.list.listName)
                    .font(.headline)
                Spacer()
                Text("\(group.tasks.count)")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 4)
            
            ForEach(group.tasks) { task in
                DetailedTaskCard(task: task)
            }
        }
    }
}

// MARK: - Today and Tomorrow Task card
struct DetailedTaskCard: View {
    @Environment(Supabase.self) var db
    let task: ToDoTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let collection = db.collections.first(where: { $0.id == task.collectionID }) {
                    Text(collection.collectionName.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(task.createdAt.formatted(.dateTime.month().day()))
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            
            Text(task.text)
                .font(.body.bold())
            
            if let desc = task.description, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}


//#Preview {
//    TaskSection()
//}
