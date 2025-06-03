//
//  DateHeaderView.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

//struct DateHeaderView: View {
//    // MARK: - Properties
//    @State var date: Date
//    @State var dateFormatter: DateFormatter
//    @Environment(\.colorScheme) var colorScheme
//    @State var groupedTasks: [Date: [ToDoTask]]
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            ZStack {
//                Circle()
//                    .fill(
//                        LinearGradient(
//                            colors: [.blue, .cyan],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(width: 20, height: 20)
//                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
//                
//                Circle()
//                    .fill(.white)
//                    .frame(width: 8, height: 8)
//            }
//            
//            // MARK: - Date + description
//            VStack(alignment: .leading, spacing: 2) {
//                Text(dateFormatter.string(from: date))
//                    .font(.title3.weight(.semibold))
//                    .foregroundColor(colorScheme == .dark ? .white : .primary)
//                
//                Text(relativeDateString(from: date))
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            // MARK: - Completed tasks count
//            HStack(spacing: 4) {
//                Image(systemName: "star.fill")
//                    .font(.caption2)
//                    .foregroundColor(.yellow)
//                
//                Text("\(groupedTasks[date]?.count ?? 0)")
//                    .font(.caption.weight(.medium))
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(
//                Capsule()
//                    .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemGray6))
//            )
//        }
//        .padding(.leading, 4)
//    }
//    
//    // MARK: - Descriptive Date
//    private func relativeDateString(from date: Date) -> String {
//        let calendar = Calendar.current
//        if calendar.isDateInToday(date) {
//            return "Today"
//        } else if calendar.isDateInYesterday(date) {
//            return "Yesterday"
//        } else {
//            let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
//            if days <= 7 {
//                return "\(days) days ago"
//            } else {
//                return dateFormatter.string(from: date)
//            }
//        }
//    }
//}

// MARK: - VERSION 2 (WORKING)
struct DateHeaderView: View {
    // MARK: - Properties
    @State var date: Date
    @State var dateFormatter: DateFormatter
    @Environment(\.colorScheme) var colorScheme
    @State var groupedTasks: [Date: [ToDoTask]]
    @ObservedObject var db: Supabase
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 20, height: 20)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
            }
            
            // MARK: - Date + description
            VStack(alignment: .leading, spacing: 2) {
                Text(db.formattedDateString(from: date))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)
                
                Text(relativeDateString(from: date))
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            // MARK: - Completed tasks count
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.yellow)
                
                Text("\(groupedTasks[date]?.count ?? 0)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemGray6))
            )
        }
        .padding(.leading, 4)
    }
    
    // MARK: - Descriptive Date with timezone fix
    private func relativeDateString(from date: Date) -> String {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let today = calendar.startOfDay(for: Date())
        let compareDate = calendar.startOfDay(for: date)
        
        if calendar.isDate(compareDate, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(compareDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? Date()) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: compareDate, to: today).day ?? 0
            if days <= 7 && days > 0 {
                return "\(days) days ago"
            } else {
                return db.formattedDateString(from: date)
            }
        }
    }
}

//#Preview {
//    DateHeaderView()
//}
