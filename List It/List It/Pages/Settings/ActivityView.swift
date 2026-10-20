//
//  ActivityView.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import SwiftUI

struct ActivityView: View {
    @Environment(Supabase.self) var db
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        sectionHeader(title: "Overview", icon: "chart.bar.fill")
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            StatCard(title: "Total Tasks", value: "\(db.tasks.count)", icon: "checkmark.circle", color: .blue)
                            StatCard(title: "Total Notes", value: "\(db.notes.count)", icon: "note.text", color: .purple)
                            StatCard(title: "Lists", value: "\(db.lists.count)", icon: "list.bullet", color: .orange)
                            StatCard(title: "Collections", value: "\(db.collections.count)", icon: "folder", color: .cyan)
                        }
                        
                        sectionHeader(title: "Performance", icon: "bolt.fill")

                        CompletionRateCard(percentage: completionPercentage)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            StatCard(title: "Completed", value: "\(completedCount)", icon: "checkmark.seal", color: .green)
                            StatCard(title: "Overdue", value: "\(overdueCount)", icon: "exclamationmark.triangle", color: .red)
                            StatCard(title: "Pinned", value: "\(pinnedCount)", icon: "pin.fill", color: .yellow)
                            StatCard(title: "Active Tasks", value: "\(db.tasks.filter { !$0.isCompleted }.count)", icon: "clock", color: .indigo)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Activity")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
            }
        }
    }
}

// MARK: - Stat card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Completion card
struct CompletionRateCard: View {
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage))%")
                    .font(.headline.bold())
            }
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Completion Rate")
                    .font(.headline)
                Text("Based on your total task history")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.2), lineWidth: 1))
    }
}


// MARK: - View extension
extension ActivityView {
    private var completedCount: Int {
        db.tasks.filter { $0.isCompleted }.count
    }
    
    private var overdueCount: Int {
        db.tasks.filter { !$0.isCompleted && $0.dueDate != nil && $0.dueDate! < Date() }.count
    }
    
    private var pinnedCount: Int {
        db.tasks.filter { $0.isPinned }.count
    }
    
    private var completionPercentage: Double {
        let total = db.tasks.count
        guard total > 0 else { return 0 }
        return (Double(completedCount) / Double(total)) * 100
    }
    
    private var backgroundGradient: some View {
        MeshGradient(width: 3, height: 3, points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.8, 0.7], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ], colors: [
            .blue.opacity(0.05), .purple.opacity(0.05), .blue.opacity(0.05),
            .cyan.opacity(0.05), .indigo.opacity(0.1), .blue.opacity(0.05),
            .blue.opacity(0.05), .purple.opacity(0.05), .blue.opacity(0.05)
        ])
        .ignoresSafeArea()
    }
    
    func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline.bold())
        .foregroundStyle(.secondary)
        .padding(.leading, 4)
    }
}

#Preview {
    ActivityView()
}
