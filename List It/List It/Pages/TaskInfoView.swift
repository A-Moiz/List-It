//
//  TaskInfoView.swift
//  List It
//
//  Created by Abdul Moiz on 05/10/2026.
//

import SwiftUI

struct TaskInfoView: View {
    @Environment(\.dismiss) var dismiss
    private let items: [(color: Color, label: String, description: String)] = [
        (.red, "Overdue", "The Task has a due date that has already passed."),
        (.orange, "Flagged", "The Task is pinned and has an upcoming due date."),
        (.yellow, "Pinned", "The Task is pinned, with no due date set."),
        (.cyan, "Normal", "No due date, and not pinned.")
    ]
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("The coloured bar on each Task shows its status at a glance.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    VStack(spacing: 0) {
                        ForEach(items.indices, id: \.self) { index in
                            infoRow(
                                color: items[index].color,
                                label: items[index].label,
                                description: items[index].description
                            )
                            
                            if index < items.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Task Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
            }
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Row
    private func infoRow(color: Color, label: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    TaskInfoView()
}
