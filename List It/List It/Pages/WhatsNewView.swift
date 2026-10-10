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
            icon: "circle.lefthalf.filled",
            title: "Choose your appearance",
            description: "Follow your iPhone's light or dark setting, or pick a different look."
        ),
        WhatsNewFeature(
            icon: "paintbrush",
            title: "A fresh new look",
            description: "Major UI updates across the app."
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
