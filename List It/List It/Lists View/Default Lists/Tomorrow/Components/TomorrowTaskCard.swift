//
//  TomorrowTaskCard.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct TomorrowTaskCard: View {
    // MARK: - Properties
    let task: ToDoTask
    let list: List
    let accentColor: Color
    let colorScheme: ColorScheme
    @ObservedObject var db: Supabase
    private var collectionName: String {
        db.collections.first(where: { $0.id == task.collectionID })?.collectionName ?? "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: "folder")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor.gradient)
                    
                    Text(collectionName)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.3)
                }
                
                Spacer()

                Circle()
                    .fill(accentColor.gradient)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(task.text)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Rectangle()
                .fill(accentColor.gradient)
                .frame(height: 2)
                .cornerRadius(1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.white.opacity(0.9)
                )
                .shadow(
                    color: colorScheme == .dark
                        ? Color.black.opacity(0.4)
                        : Color.black.opacity(0.08),
                    radius: 10,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [Color.white.opacity(0.1), Color.clear]
                            : [Color.white.opacity(0.8), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

//#Preview {
//    TomorrowTaskCard()
//}
