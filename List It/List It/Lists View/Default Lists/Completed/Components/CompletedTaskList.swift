//
//  CompletedTaskList.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct CompletedTaskList: View {
    // MARK: - Properties
    @State var groupedTasks: [Date: [ToDoTask]]
    @State var dateFormatter: DateFormatter
    @ObservedObject var db: Supabase
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 50) {
                if groupedTasks.isEmpty {
                    Text("No achievements to display")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(Array(groupedTasks.keys.sorted(by: >).enumerated()), id: \.element) { index, date in
                        CompletedTaskGroup(date: date, isLast: index == groupedTasks.keys.count - 1, groupedTasks: groupedTasks, dateFormatter: dateFormatter, db: db)
                    }
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    CompletedTaskList()
//}
