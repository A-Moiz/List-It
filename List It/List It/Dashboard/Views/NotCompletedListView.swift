//
//  NotCompletedListView.swift
//  List It
//
//  Created by Abdul Moiz on 15/04/2025.
//

import SwiftUI

struct NotCompletedListView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper

    private var notCompletedTasksByList: [String: [Task]] {
        var grouped: [String: [Task]] = [:]
        for list in db.lists {
            let tasks = (list.tasks ?? []).filter { !$0.isCompleted && !$0.isDeleted }
            if !tasks.isEmpty {
                grouped[list.listName] = tasks
            }
        }
        return grouped
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.background(for: colorScheme)
                    .ignoresSafeArea()

                if notCompletedTasksByList.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("All tasks are completed!")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            ForEach(notCompletedTasksByList.sorted(by: { $0.key < $1.key }), id: \.key) { (listName, tasks) in
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 12, height: 12)

                                        Text(listName)
                                            .font(.headline)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                    .padding(.leading, 4)

                                    ForEach(tasks, id: \.id) { task in
                                        HStack(alignment: .top, spacing: 20) {
                                            VStack {
                                                Circle()
                                                    .fill(Color.orange)
                                                    .frame(width: 8, height: 8)
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 2)
                                                    .frame(maxHeight: .infinity)
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(task.text)
                                                    .font(.body)
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                                if let desc = task.description, !desc.isEmpty {
                                                    Text(desc)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }

                                                if let dueDate = task.dueDate {
                                                    HStack(spacing: 5) {
                                                        Image(systemName: "calendar")
                                                            .foregroundColor(.gray)

                                                        Text(dueDate, style: .date)
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                            )
                                        }
                                        .padding(.leading, 8)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle("Pending Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NotCompletedListView(db: Supabase(), helper: Helper())
}
