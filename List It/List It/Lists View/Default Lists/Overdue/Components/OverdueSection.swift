//
//  OverdueSection.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct OverdueSection: View {
    // MARK: - Properties
    let list: List
    let tasks: [ToDoTask]
    let accentColor: Color
    let colorScheme: ColorScheme
    @ObservedObject var db: Supabase
    
    private func daysOverdue(for task: ToDoTask) -> Int {
        guard let dueDate = task.dueDate else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: dueDateStart, to: today).day ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // MARK: - List/Task info
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(accentColor.gradient)
                        .frame(width: 4, height: 28)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(list.listName)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text("\(tasks.count) overdue")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                        }
                        .textCase(.uppercase)
                        .tracking(0.3)
                    }
                }
                
                Spacer()
                
                // MARK: - Task count
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    
                    Text("\(tasks.count)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.red.gradient)
                )
            }
            .padding(.horizontal, 24)
            
            // MARK: - Task card
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    OverdueTaskCard(
                        task: task,
                        list: list,
                        accentColor: accentColor,
                        colorScheme: colorScheme,
                        db: db,
                        isStaggered: false
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 32)
    }
}

//#Preview {
//    OverdueSection()
//}
