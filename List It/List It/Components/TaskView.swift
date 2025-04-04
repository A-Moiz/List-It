//
//  TaskView.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

struct TaskView: View {
    @Binding var task: Task
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(.gray)
                .frame(height: 50)
            
            HStack(spacing: 20) {
                Button {
                    task.isCompleted.toggle()
                } label: {
                    Image(systemName: task.isCompleted ? "circle.fill" : "circle")
                }
                
                VStack(alignment: .leading) {
                    Text(task.text)
                        .bold()
                        .strikethrough(task.isCompleted)
                    
                    if let description = task.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .strikethrough(task.isCompleted)
                    }
                    
                    // Date
                    HStack {
                        
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var task = Task(id: UUID().uuidString, text: "Buy Milk", description: "Buy from Tesco", dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false)
    TaskView(task: $task)
}
