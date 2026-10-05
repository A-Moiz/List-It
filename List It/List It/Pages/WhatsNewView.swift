//
//  WhatsNewView.swift
//  List It
//
//  Created by Abdul Moiz on 01/10/2026.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenVersion: Int = 0
    var currentVersion: Int
    
    private let features: [WhatsNewFeature] = [
        WhatsNewFeature(
            icon: "paintbrush",
            title: "A cleaner look throughout",
            description: "Several pages have been refreshed with a simpler, more minimal design."
        ),
        WhatsNewFeature(
            icon: "bell.badge",
            title: "Reminders",
            description: "Schedule a Task to get notified for it."
        ),
        WhatsNewFeature(
            icon: "text.document",
            title: "Feedback",
            description: "A form has been provided in Settings for you to request features or give feedback"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's New")
                            .font(.largeTitle.bold())
                        Text("Here's what's changed in this update.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(features) { feature in
                            featureRow(feature)
                        }
                    }
                }
                .padding()
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
