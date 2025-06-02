//
//  taskListView.swift
//  List It
//
//  Created by Abdul Moiz on 02/05/2025.
//

import SwiftUI

struct TaskListView: View {
    // MARK: - Properties
    @Binding var collection: Collection
    @Binding var list: List
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    let collectionColor: Color

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                let filteredTasks = db.userTasks.filter { $0.collectionID == collection.id && !$0.isCompleted }
                let sortedTasks = filteredTasks.sorted {
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned && !$1.isPinned
                    } else {
                        return $0.createdAt > $1.createdAt
                    }
                }

                if sortedTasks.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        collectionColor: collectionColor,
                        message: "No tasks in this collection",
                        subMessage: "Add a Task to get started"
                    )
                } else {
                    ForEach(
                        db.userTasks.indices
                            .filter { db.userTasks[$0].collectionID == collection.id && !db.userTasks[$0].isCompleted }
                            .sorted(by: { sortFunc(db.userTasks[$0], db.userTasks[$1]) }),
                        id: \.self
                    ) { index in
                        TaskView(
                            task: $db.userTasks[index],
                            collection: $collection,
                            list: $list,
                            db: db,
                            helper: helper
                        )
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    func sortFunc(_ a: ToDoTask, _ b: ToDoTask) -> Bool {
        if a.isPinned != b.isPinned {
            return a.isPinned && !b.isPinned
        } else {
            return a.createdAt > b.createdAt
        }
    }
}

//#Preview {
//    let sampleTask = ToDoTask(id: "", text: "", dateCreated: Date(), isCompleted: false, isDeleted: false, isPinned: false)
//    
//    let sampleCollection = Collection(id: "", collectionName: "", bgColorHex: "", dateCreated: Date())
//    
//    let sampleList = List(id: "", listIcon: "", listName: "", isDefault: false, bgColorHex: "", userId: "", isPinned: false)
//
//    TaskListView(
//        sortedTasks: sampleCollection.tasks,
//        collection: .constant(sampleCollection),
//        list: .constant(sampleList),
//        db: Supabase(),
//        helper: Helper(),
//        collectionColor: .blue
//    )
//}
