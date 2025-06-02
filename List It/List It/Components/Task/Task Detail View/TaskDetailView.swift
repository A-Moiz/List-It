//
//  TaskDetailView.swift
//  List It
//
//  Created by Abdul Moiz on 10/04/2025.
//

import SwiftUI

struct TaskDetailView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var task: ToDoTask
    @Binding var collection: Collection
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var editedText: String = ""
    @State private var editedDescription: String = ""
    @State private var editedDueDate: Date? = nil
    @State private var showDatePicker: Bool = false
    @State private var animateContent: Bool = false
    @State private var circleData: [CircleModel] = []
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: View background
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color(UIColor.systemBackground).opacity(0.3) : Color(UIColor.systemBackground),
                        colorScheme == .dark ? Color.black.opacity(0.9) : Color(UIColor.systemBackground).opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(
                    ZStack {
                        ForEach(circleData) { circle in
                            Circle()
                                .fill(collection.bgColor.opacity(colorScheme == .dark ? 0.2 : 0.5))
                                .frame(width: circle.size)
                                .position(x: circle.x, y: circle.y)
                                .animation(.easeInOut(duration: 2.0), value: circle.x)
                        }
                    }
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 22) {
                        // MARK: - Task title field
                        TaskTitleView(editedText: $editedText, collection: $collection, animateContent: $animateContent)
                        
                        // MARK: - Description editor
                        TaskDescriptionView(editedDescription: $editedDescription, collection: $collection, animateContent: $animateContent)
                        
                        // MARK: - Due date section
                        TaskDueDateView(editedDueDate: $editedDueDate, showDatePicker: $showDatePicker, bgColor: collection.bgColor, db: db)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // MARK: - Task metadata card
                        TaskMetadataCardView(task: $task, collection: $collection, db: db)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // MARK: - Save button
                        Button {
                            withAnimation {
                                db.updateTask(task: task, text: editedText, description: editedDescription, dueDate: editedDueDate) { success, errorMessage in
                                    if !success, let error = errorMessage {
                                        helper.showAlertWithMessage("Error updating Task: \(error)")
                                    } else {
                                        db.fetchUserTasks { success, errorMessage in
                                            if !success, let error = errorMessage {
                                                helper.showAlertWithMessage("Error fetching new updated Task: \(error)")
                                            } else {
                                                dismiss()
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [collection.bgColor, collection.bgColor.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: collection.bgColor.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Task Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(collection.collectionName)
                            .font(.caption)
                            .foregroundColor(collection.bgColor)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.7))
                    }
                }
            }
            .onAppear {
                editedText = task.text
                editedDescription = task.description ?? ""
                editedDueDate = task.dueDate
                generateRandomCircles()
                
                timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 2.0)) {
                        generateRandomCircles()
                    }
                }
                
                withAnimation(.easeOut(duration: 0.4)) {
                    animateContent = true
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Function for background
    func generateRandomCircles() {
        circleData = (0..<15).map { _ in
            CircleModel(
                size: CGFloat.random(in: 50...200),
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
    }
}

//#Preview {
//    @Previewable @State var task = ToDoTask(
//        id: UUID().uuidString,
//        text: "Buy Milk",
//        description: "Buy from Tesco",
//        dateCreated: Date(),
//        dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
//        isCompleted: false,
//        dateCompleted: nil,
//        isDeleted: false,
//        isPinned: false
//    )
//    @Previewable @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: [], notes: [])
//    TaskDetailView(task: $task, collection: $collection, db: Supabase(), helper: Helper())
//}
