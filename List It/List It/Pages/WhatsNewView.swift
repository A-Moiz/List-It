//
//  WhatsNewView.swift
//  List It
//
//  Created by Abdul Moiz on 01/10/2026.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenVersion: Int = 0
    var currentVersion: Int
    private let features: [WhatsNewFeature] = [
        WhatsNewFeature(
            icon: "calendar.badge.clock",
            title: "Scheduled Tasks",
            description: "See every scheduled Task in one place. Browse by month, pick a day, and jump back to today anytime. Find it in the menu on the home screen."
        ),
        WhatsNewFeature(
            icon: "bell.badge",
            title: "Separate Reminders",
            description: "Due dates and alerts are now independent. Set a final deadline for your task while picking a completely different time to receive your alert notification."
        ),
        WhatsNewFeature(
            icon: "arrow.uturn.backward",
            title: "Completion Undo",
            description: "Accidentally checked off a task? You can now reverse and restore any tasks completed today directly from the completed list."
        ),
        WhatsNewFeature(
            icon: "rectangle.grid.1x2",
            title: "Redesigned Completed View",
            description: "Enjoy a beautiful, minimal, and architectural archive feed."
        ),
        WhatsNewFeature(
            icon: "list.bullet",
            title: "Interactive Default Lists",
            description: "All tasks appearing in your smart default lists are now fully interactive. Simply tap on any task to instantly open its details and update its properties."
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Here's what's changed in this update")
                    .foregroundStyle(.secondary)
                    .padding()
                Divider()
                    .padding()
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(features) { feature in
                        featureRow(feature)
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        lastSeenVersion = currentVersion
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("What's new")
            .navigationBarTitleDisplayMode(.inline)
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Feature row
    private func featureRow(_ feature: WhatsNewFeature) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundStyle(Color.orange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WhatsNewView(currentVersion: 1)
}
