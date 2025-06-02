//
//  CompletedTaskGroup.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct CompletedTaskGroup: View {
    // MARK: - Properties
    @State var date: Date
    @State var isLast: Bool
    @State var groupedTasks: [Date: [ToDoTask]]
    @State var dateFormatter: DateFormatter
    @ObservedObject var db: Supabase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DateHeaderView(date: date, dateFormatter: dateFormatter, groupedTasks: groupedTasks)
            
            VStack(spacing: 16) {
                ForEach(Array((groupedTasks[date] ?? []).enumerated()), id: \.element.id) { index, task in
                    CompletedTaskView(task: task, dateFormatter: dateFormatter, db: db, isLastInGroup: index == (groupedTasks[date]?.count ?? 0) - 1, isLastGroup: isLast)
                }
            }
        }
    }
}

//#Preview {
//    CompletedTaskGroup()
//}
