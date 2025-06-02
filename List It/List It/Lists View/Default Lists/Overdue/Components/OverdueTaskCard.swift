//
//  OverdueTaskCard.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct OverdueTaskCard: View {
    // MARK: - Properties
    let task: ToDoTask
    let list: List
    let accentColor: Color
    let colorScheme: ColorScheme
    @ObservedObject var db: Supabase
    let isStaggered: Bool

    private var collectionName: String {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName ?? "Unknown"
    }
    
    private var daysOverdue: Int {
        guard let dueDate = task.dueDate else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: dueDateStart, to: today).day ?? 0
    }
    
    private var urgencyLevel: (color: Color, text: String, bgColor: Color) {
        switch daysOverdue {
        case 0...2:
            return (.orange, "MILD", .orange.opacity(0.15))
        case 3...7:
            return (.red, "HIGH", .red.opacity(0.15))
        default:
            return (.purple, "CRITICAL", .purple.opacity(0.15))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("\(daysOverdue)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(urgencyLevel.color)
                        
                        Text("DAYS")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(urgencyLevel.color)
                            .tracking(0.5)
                    }
                    
                    Text("overdue")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.3)
                }
                
                Spacer()
                
                Text(urgencyLevel.text)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(urgencyLevel.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(urgencyLevel.bgColor)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.text)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // MARK: - Collection and due date
                VStack(alignment: .leading, spacing: 4) {
                    Text(collectionName)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(accentColor)
                        .textCase(.uppercase)
                        .tracking(0.4)
                    
                    if let dueDate = task.dueDate {
                        Text("Due: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
            }
            
            // MARK: - Urgent indicator
            HStack {
                Rectangle()
                    .fill(urgencyLevel.color.gradient)
                    .frame(height: 3)
                    .cornerRadius(1.5)
                
                Circle()
                    .fill(urgencyLevel.color.gradient)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.white.opacity(0.9)
                )
                .shadow(
                    color: urgencyLevel.color.opacity(0.2),
                    radius: 12,
                    x: 0,
                    y: isStaggered ? 8 : 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [urgencyLevel.color.opacity(0.3), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .offset(y: isStaggered ? 12 : 0)
    }
}

//#Preview {
//    OverdueTaskCard()
//}
