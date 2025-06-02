//
//  DueDateStatusView.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct DueDateStatusView: View {
    // MARK: - Properties
    @State var dueDate: Date
    @State var completedDate: Date

    private var daysDifference: Int {
        let calendar = Calendar.current
        let dueDateStart = calendar.startOfDay(for: dueDate)
        let completedDateStart = calendar.startOfDay(for: completedDate)
        return calendar.dateComponents([.day], from: dueDateStart, to: completedDateStart).day ?? 0
    }

    private var status: (color: Color, backgroundColor: Color, icon: String) {
        switch daysDifference {
        case 0:
            return (.green, .green.opacity(0.15), "checkmark.circle.fill")
        case ..<0:
            return (.blue, .blue.opacity(0.15), "clock.arrow.2.circlepath")
        default:
            return (.orange, .orange.opacity(0.15), "exclamationmark.triangle.fill")
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(status.color)

            if daysDifference == 0 {
                Text("ON TIME")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundColor(status.color)
                    .tracking(0.3)
            } else {
                VStack(spacing: 1) {
                    Text("\(abs(daysDifference))")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(status.color)

                    Text(abs(daysDifference) == 1 ? "DAY" : "DAYS")
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                        .foregroundColor(status.color)
                        .tracking(0.4)

                    Text(daysDifference > 0 ? "LATE" : "EARLY")
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                        .foregroundColor(status.color)
                        .tracking(0.3)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(status.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(status.color.opacity(0.3), lineWidth: 1)
        )
    }
}

//#Preview {
//    DueDateStatusView()
//}
