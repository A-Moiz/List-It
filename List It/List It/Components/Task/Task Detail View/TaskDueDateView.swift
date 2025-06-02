//
//  TaskDueDateView.swift
//  List It
//
//  Created by Abdul Moiz on 04/05/2025.
//

import SwiftUI

struct TaskDueDateView: View {
    // MARK: - Properties
    @Binding var editedDueDate: Date?
    @Binding var showDatePicker: Bool
    var bgColor: Color
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: Text title
            Text("DUE DATE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray)
                .padding(.horizontal, 4)

            VStack(spacing: 16) {
                HStack {
                    // MARK: - Caldendar icon with due date (if set)
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundColor(bgColor)
                            .font(.system(size: 18))

                        if let due = editedDueDate {
                            Text(db.dateFormatterWithoutTime(due))
                                .font(.subheadline)
                        } else {
                            Text("No due date set")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    // MARK: - Set/Change due date button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDatePicker.toggle()
                        }
                    } label: {
                        Text(editedDueDate == nil ? "Set" : "Change")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(bgColor)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(bgColor.opacity(0.3), lineWidth: 1)
                )

                if showDatePicker {
                    VStack(spacing: 12) {
                        // MARK: - Date picker
                        DatePicker("Select Date", selection: Binding (
                            get: { editedDueDate ?? Date() },
                            set: { editedDueDate = $0 }
                        ), in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(bgColor)

                        // MARK: - Remove due date
                        // Only show up if due date isn't nil
                        if editedDueDate != nil {
                            Button {
                                withAnimation {
                                    editedDueDate = nil
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                    Text("Remove Due Date")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.1))
                                )
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(bgColor.opacity(0.3), lineWidth: 1)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

//#Preview {
//    TaskDueDateView()
//}
