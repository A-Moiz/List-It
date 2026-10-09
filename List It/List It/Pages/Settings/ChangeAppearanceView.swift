//
//  ChangeAppearanceView.swift
//  List It
//
//  Created by Abdul Moiz on 09/10/2026.
//

import SwiftUI

struct ChangeAppearanceView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    @State private var selectedAppearance: AppAppearance = .device
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(AppAppearance.allCases, id: \.self) { option in
                    appearanceRow(option)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
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
                        saveAppearance()
                    } label: {
                        Text("Save")
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                selectedAppearance = appearance
            }
        }
    }
    
    // MARK: - Row
    private func appearanceRow(_ option: AppAppearance) -> some View {
        let isSelected = selectedAppearance == option
        
        return Button {
            selectedAppearance = option
        } label: {
            HStack(spacing: 14) {
                swatch(for: option)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(option.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.orange : .secondary)
                    .font(.system(size: 20))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 3)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
    
    // MARK: - Preview swatch
    private func swatch(for option: AppAppearance) -> some View {
        Group {
            if let color = option.backgroundColor {
                color
            } else {
                HStack(spacing: 0) {
                    Color.white
                    Color.black
                }
            }
        }
        .frame(width: 56, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Save
    private func saveAppearance() {
        appearance = selectedAppearance
        dismiss()
    }
}

#Preview {
    ChangeAppearanceView()
}
