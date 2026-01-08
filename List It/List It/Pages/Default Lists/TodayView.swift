//
//  TodayView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct TodayView: View {
    @Environment(Supabase.self) var db
    @State private var searchText: String = ""

    private var groupedData: [(list: List, tasks: [ToDoTask])] {
        // Normalize search: lowercase and remove all whitespaces
        let cleanQuery = searchText.lowercased().replacingOccurrences(of: " ", with: "")
        
        let filteredLists = cleanQuery.isEmpty ? db.lists : db.lists.filter {
            $0.listName.lowercased().replacingOccurrences(of: " ", with: "").contains(cleanQuery)
        }
        
        return filteredLists.compactMap { list in
            let todayTasks = db.tasks.filter {
                $0.listID == list.id &&
                !$0.isCompleted &&
                Calendar.current.isDateInToday($0.dueDate ?? Date.distantPast)
            }
            return todayTasks.isEmpty ? nil : (list: list, tasks: todayTasks)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if groupedData.isEmpty {
                    ContentUnavailableView("All Done for Today", systemImage: "sun.max.fill")
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(groupedData, id: \.list.id) { group in
                            TaskSection(group: group)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search Lists")
        }
    }
}


#Preview {
    TodayView()
        .environment(Supabase())
}
