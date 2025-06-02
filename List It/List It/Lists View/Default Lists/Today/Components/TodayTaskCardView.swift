//
//  TodayTaskCardView.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct TodayTaskCardView: View {
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
        return dueDate < Date()
    }
    
    private var cardGradient: LinearGradient {
        return LinearGradient(
            colors: colorScheme == .dark
            ? [Color(.systemGray5), Color(.systemGray6)]
            : [Color.white, listAccentColor.opacity(0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header with collection info
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
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar.circle.fill")
                        .foregroundColor(listAccentColor)
                        .font(.caption)
                    Text("Due Today")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(listAccentColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(listAccentColor.opacity(0.1))
                )
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

                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("Created: \(task.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(listAccentColor)
                            .font(.caption)
                        Text(list.createdAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption.weight(.medium))
                            .foregroundColor(listAccentColor)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(listAccentColor.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: colorScheme == .dark
            ? Color.black.opacity(0.3)
            : listAccentColor.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

//#Preview {
//    TodayTaskCardView()
//}
