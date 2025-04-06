//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 06/04/2025.
//

import SwiftUI

struct CollectionView: View {
    @Binding var collection: Collection
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Tab = .task
    @State private var tabProgress: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(collection.collectionName)
                    .font(.headline)
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(hex: collection.bgColorHex))
            .cornerRadius(10)
            .shadow(radius: 2)
            
            if isExpanded {
                ScrollView {
                    TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
                        .padding(.top)
                    
                    TabContentView(selectedTab: $selectedTab, tabProgress: $tabProgress, collection: $collection)
                }
            }
        }
        .padding()
    }
}

struct NoteRowView: View {
    var note: Note
    var body: some View {
        Text(note.text)
    }
}

#Preview {
    let sampleTasks = [
        Task(id: UUID().uuidString, text: "Buy groceries", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false),
        Task(id: UUID().uuidString, text: "Read SwiftUI book", description: nil, dateCreated: Date(), dueDate: nil, isCompleted: false, dateCompleted: nil, isDeleted: false, isPinned: false)
    ]
    
    let sampleNotes = [
        Note(id: UUID().uuidString, text: "Don't forget to water the plants.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false),
        Note(id: UUID().uuidString, text: "Meeting notes from today.", dateCreated: Date(), isDeleted: false, bgColorHex: "#FFCC00", isPinned: false)
    ]
    @State var collection = Collection(id: UUID().uuidString, collectionName: "List It", bgColorHex: "#87CEEB", dateCreated: Date(), tasks: sampleTasks, notes: sampleNotes)
    CollectionView(collection: $collection)
}
