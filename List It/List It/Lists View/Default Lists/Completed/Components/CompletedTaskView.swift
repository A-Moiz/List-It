//
//  CompletedTaskView.swift
//  List It
//
//  Created by Abdul Moiz on 24/05/2025.
//

import SwiftUI

struct CompletedTaskView: View {
    // MARK: - Properties
    let task: ToDoTask
    let dateFormatter: DateFormatter
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase
    let isLastInGroup: Bool
    let isLastGroup: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            CompletedTimelineView(isLastInGroup: isLastGroup, isLastGroup: isLastGroup)
            CompletedTaskContent(task: task, dateFormatter: dateFormatter, db: db)
        }
        .padding(.leading, 12)
    }
}

//#Preview {
//    CompletedTaskView()
//}
