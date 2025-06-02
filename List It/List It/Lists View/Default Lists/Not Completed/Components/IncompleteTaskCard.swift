//
//  IncompleteTaskCard.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct IncompleteTaskCard: View {
    // MARK: - Properties
    let task: ToDoTask
    let list: List
    let listAccentColor: Color
    let colorScheme: ColorScheme
    @ObservedObject var db: Supabase
    
    private var collectionName: String {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName ?? "Unknown"
    }
    
    private var isOverdue: Bool {
        guard let dueDate = task.dueDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let taskDueDate = calendar.startOfDay(for: dueDate)
        
        return taskDueDate < today
    }
    
    private var cardGradient: LinearGradient {
        if isOverdue {
            return LinearGradient(
                colors: colorScheme == .dark
                ? [Color.red.opacity(0.2), Color.red.opacity(0.1)]
                : [Color.red.opacity(0.1), Color.red.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: colorScheme == .dark
                ? [Color(.systemGray5), Color(.systemGray6)]
                : [Color.white, Color(.systemGray6).opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(listAccentColor)
                    .frame(width: 4, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(collectionName)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // MARK: - Creation date
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Created")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(task.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // MARK: - Main content
            VStack(alignment: .leading, spacing: 12) {
                Text(task.text)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                // MARK: - Due date if exists
                if let dueDate = task.dueDate {
                    HStack(spacing: 8) {
                        Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "calendar.badge.clock")
                            .foregroundColor(isOverdue ? .red : .orange)
                            .font(.subheadline)
                        
                        Text(isOverdue ? "Overdue:" : "Due:")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(isOverdue ? .red : .orange)
                        
                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption.weight(.medium))
                            .foregroundColor(isOverdue ? .red : .orange)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isOverdue ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark
                    ? Color.white.opacity(0.1)
                    : Color.black.opacity(0.05),
                    lineWidth: 1
                )
        )
        .shadow(
            color: colorScheme == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

//#Preview {
//    IncompleteTaskCard()
//}
