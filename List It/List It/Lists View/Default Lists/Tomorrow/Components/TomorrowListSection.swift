//
//  TomorrowListSection.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct TomorrowListSection: View {
    // MARK: - Properties
    let list: List
    let tasks: [ToDoTask]
    let accentColor: Color
    let colorScheme: ColorScheme
    @ObservedObject var db: Supabase
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Section header
            HStack {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(accentColor.gradient)
                        .frame(width: 4, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(list.listName)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s") planned")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.3)
                    }
                }
                
                Spacer()
                
                // MARK: - Progress indicator
                Text("\(tasks.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(accentColor.gradient)
                    )
            }
            .padding(.horizontal, 24)
            
            // MARK: - Tasks grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(tasks, id: \.id) { task in
                    TomorrowTaskCard(
                        task: task,
                        list: list,
                        accentColor: accentColor,
                        colorScheme: colorScheme,
                        db: db
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 32)
    }
}

//#Preview {
//    TomorrowListSection()
//}
