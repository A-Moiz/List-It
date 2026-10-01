//
//  ListStyleView.swift
//  List It
//
//  Created by Abdul Moiz on 01/10/2026.
//

import SwiftUI

enum ListDisplayStyle: String, CaseIterable {
    case card
    case list
}

extension ListDisplayStyle: RawRepresentable {}

struct ListStyleView: View {
    @Environment(Supabase.self) var db
    @Environment(\.dismiss) var dismiss
    @AppStorage("listDisplayStyle") private var displayStyle: ListDisplayStyle = .card
    @State private var selectedStyle: ListDisplayStyle = .card
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                styleRow(
                    style: .card,
                    title: "Card",
                    subtitle: "Compact tiles in a grid"
                )
                
                styleRow(
                    style: .list,
                    title: "List",
                    subtitle: "Full-width rows you can swipe"
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Choose List style")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        updateListStyle()
                    } label: {
                        Text("Save")
                    }
                }
            }
            .onAppear {
                selectedStyle = displayStyle
            }
        }
    }
    
    // MARK: - Row
    private func styleRow(style: ListDisplayStyle, title: String, subtitle: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedStyle = style
            }
        } label: {
            HStack(spacing: 14) {
                stylePreview(for: style)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: selectedStyle == style ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedStyle == style ? Color.orange : .secondary)
                    .font(.system(size: 20))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selectedStyle == style ? Color.orange.opacity(0.08) : Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selectedStyle == style ? Color.orange : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Tiny layout preview swatch
    private func stylePreview(for style: ListDisplayStyle) -> some View {
        Group {
            switch style {
            case .card:
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 3)
                    RoundedRectangle(cornerRadius: 3)
                }
            case .list:
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 3)
                    RoundedRectangle(cornerRadius: 3)
                }
            }
        }
        .foregroundStyle(.secondary.opacity(0.4))
        .frame(width: 40, height: 40)
    }
    
    // MARK: - Save to AppStorage
    private func updateListStyle() {
        displayStyle = selectedStyle
        dismiss()
    }
}

#Preview {
    ListStyleView()
        .environment(Supabase())
}
