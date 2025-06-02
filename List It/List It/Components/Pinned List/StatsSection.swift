//
//  StatsSection.swift
//  List It
//
//  Created by Abdul Moiz on 29/05/2025.
//

import SwiftUI

struct StatsSection: View {
    // MARK: - Properties
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Binding var list: List
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let taskCount = db.userTasks.filter { $0.listID == list.id && !$0.isDeleted && !$0.isCompleted }.count
        let noteCount = db.userNotes.filter { $0.listID == list.id && !$0.isDeleted }.count
        
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Circle().fill(list.bgColor).frame(width: 8, height: 8)
                Text("\(taskCount) \(taskCount == 1 ? "Task" : "Tasks")")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.8) : Color.primary)
                Spacer()
            }
            HStack(spacing: 6) {
                Circle().fill(list.bgColor.opacity(0.7)).frame(width: 8, height: 8)
                Text("\(noteCount) \(noteCount == 1 ? "Note" : "Notes")")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.8) : Color.primary)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}
    

//#Preview {
//    StatsSection()
//}
