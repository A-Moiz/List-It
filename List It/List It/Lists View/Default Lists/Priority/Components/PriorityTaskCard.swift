//
//  PriorityTaskCard.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct PriorityTaskCard: View {
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
        let taskDueDay = calendar.startOfDay(for: dueDate)
        
        return taskDueDay < today
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Priority icon
            VStack(spacing: 4) {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.orange.gradient)
                    .font(.subheadline)
                
                if isOverdue {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption2)
                }
            }
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isOverdue {
                        Text("OVERDUE")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    }
                }
                
                HStack(spacing: 8) {
                    if let desc = task.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(collectionName)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(listAccentColor)
                    
                    if let dueDate = task.dueDate {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(isOverdue ? .red : .secondary)
                    }
                }
            }
            
            Spacer()
            
            // MARK: - Accent line
            RoundedRectangle(cornerRadius: 2)
                .fill(listAccentColor.gradient)
                .frame(width: 3, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    colorScheme == .dark
                    ? Color(.systemGray5).opacity(0.8)
                    : Color.white.opacity(0.9)
                )
                .shadow(
                    color: colorScheme == .dark
                    ? .black.opacity(0.3)
                    : .orange.opacity(0.1),
                    radius: 4,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    .orange.opacity(0.2),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    PriorityTaskCard()
//}
