//
//  TabContentView.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct TabContentView: View {
    @Binding var selectedTab: Tab
    @Binding var tabProgress: CGFloat
    private var scrollPositionBinding: Binding<Tab?> {
        Binding<Tab?>(
            get: { selectedTab },
            set: { newValue in
                if let newTab = newValue {
                    selectedTab = newTab
                }
            }
        )
    }
    @Binding var collection: Collection
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        if let tasks = collection.tasks, !tasks.isEmpty {
                            ForEach(tasks.indices, id: \.self) { index in
                                let taskBinding = Binding<Task>(
                                    get: { collection.tasks![index] },
                                    set: { newTask in
                                        var updatedTasks = collection.tasks!
                                        updatedTasks[index] = newTask
                                        collection.tasks = updatedTasks
                                    }
                                )
                                
                                TaskView(task: taskBinding)
                            }
                        } else {
                            Text("No tasks in this Collection.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .id(Tab.task)
                    .containerRelativeFrame(.horizontal)
                    
                    Text("Notes")
                        .id(Tab.note)
                        .containerRelativeFrame(.horizontal)
                }
                .scrollTargetLayout()
                .offsetX { value in
                    let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
                    tabProgress = max(min(progress, 1), 0)
                }
            }
            .scrollPosition(id: scrollPositionBinding)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tab = .task
    @Previewable @State var tabProgress: CGFloat = 0
    let sampleTasks = [
        Task(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
    ]
    
    let sampleNotes = [
        Note(id: UUID().uuidString, text: "Don't forget to water the plants.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false),
        Note(id: UUID().uuidString, text: "Meeting notes from today.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false)
    ]
    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: sampleTasks, notes: sampleNotes)
    TabContentView(selectedTab: $selectedTab, tabProgress: $tabProgress, collection: $collection)
}
