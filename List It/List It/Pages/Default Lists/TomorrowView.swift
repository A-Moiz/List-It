//
//  TomorrowView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct TomorrowView: View {
    @Environment(Supabase.self) var db
    @State private var searchText: String = ""

    private var groupedData: [(list: List, tasks: [ToDoTask])] {
        let cleanQuery = searchText.lowercased().replacingOccurrences(of: " ", with: "")
        
        let filteredLists = cleanQuery.isEmpty ? db.lists : db.lists.filter {
            $0.listName.lowercased().replacingOccurrences(of: " ", with: "").contains(cleanQuery)
        }
        
        return filteredLists.compactMap { list in
            let tomorrowTasks = db.tasks.filter {
                $0.listID == list.id &&
                !$0.isCompleted &&
                Calendar.current.isDateInTomorrow($0.dueDate ?? Date.distantPast)
            }
            return tomorrowTasks.isEmpty ? nil : (list: list, tasks: tomorrowTasks)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if groupedData.isEmpty {
                    ContentUnavailableView("Clear Schedule", systemImage: "sunrise.fill")
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(groupedData, id: \.list.id) { group in
                            TaskSection(group: group)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Tomorrow")
            .toolbarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search Lists")
        }
    }
}

#Preview {
    TomorrowView()
        .environment(Supabase())
}
