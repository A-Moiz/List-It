//
//  ScheduledView.swift
//  List It
//
//  Created by Abdul Moiz on 17/10/2026.
//

import SwiftUI

struct ScheduledView: View {
    @Environment(Supabase.self) var db
    @AppStorage("appAppearance") private var appearance: AppAppearance = .device
    @State private var displayedMonth: Date = ScheduledView.firstOfMonth(for: Date())
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var selectedTask: ToDoTask?
    private var calendar: Calendar {
        Calendar.current
    }
    private static func firstOfMonth(for date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }
    private var scheduledTasks: [ToDoTask] {
        db.tasks.filter { $0.schedule != nil && !$0.isCompleted && !$0.isDeleted }
    }
    private var daysWithTasks: Set<Date> {
        Set(scheduledTasks.compactMap { task in
            task.schedule.map { calendar.startOfDay(for: $0) }
        })
    }
    private var tasksForSelectedDate: [ToDoTask] {
        scheduledTasks
            .filter { task in
                guard let schedule = task.schedule else { return false }
                return calendar.isDate(schedule, inSameDayAs: selectedDate)
            }
            .sorted { ($0.schedule ?? .distantFuture) < ($1.schedule ?? .distantFuture) }
    }
    private var isShowingCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...]) + Array(symbols[..<start])
    }
    private var monthDays: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let weekday = calendar.component(.weekday, from: displayedMonth)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: displayedMonth) {
                days.append(date)
            }
        }
        return days
    }
    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            displayedMonth = newMonth
            // Keep the selected date inside the month being shown, so the
            // tasks underneath always match a visible day.
            selectedDate = calendar.isDate(newMonth, equalTo: Date(), toGranularity: .month)
            ? calendar.startOfDay(for: Date())
            : newMonth
        }
    }
    private var isViewingToday: Bool {
        isShowingCurrentMonth && calendar.isDateInToday(selectedDate)
    }
    private func jumpToToday() {
        withAnimation(.easeOut(duration: 0.2)) {
            displayedMonth = ScheduledView.firstOfMonth(for: Date())
            selectedDate = calendar.startOfDay(for: Date())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                calendarSection
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                Divider()
                
                tasksSection
            }
            .navigationTitle("Scheduled")
            .navigationBarTitleDisplayMode(.inline)
            .background(appearance.backgroundColor ?? Color(.systemGroupedBackground))
            .toolbar {
                if !isViewingToday {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Today") {
                            jumpToToday()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - Calendar
    private var calendarSection: some View {
        VStack(spacing: 6) {
            monthHeader
            weekdayRow
            dayGrid
        }
    }
    
    // MARK: - Months header
    private var monthHeader: some View {
        HStack {
            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 22) {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .opacity(isShowingCurrentMonth ? 0 : 1)
                .disabled(isShowingCurrentMonth)
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.orange)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Weekday row
    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Calendar grid
    private var dayGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: 2
        ) {
            ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }
    
    // MARK: - Calendar cell
    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isPast = date < calendar.startOfDay(for: Date())
        let hasTasks = daysWithTasks.contains(calendar.startOfDay(for: date))
        
        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected || isToday ? .semibold : .regular))
                    .foregroundStyle(dayTextColor(isSelected: isSelected, isToday: isToday, isPast: isPast))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(isSelected ? Color.orange : Color.clear)
                    )
                
                Circle()
                    .fill(dotColor(hasTasks: hasTasks, isSelected: isSelected))
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Text colour
    private func dayTextColor(isSelected: Bool, isToday: Bool, isPast: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return .orange }
        return isPast ? .secondary : .primary
    }
    
    // MARK: - Dot colour
    private func dotColor(hasTasks: Bool, isSelected: Bool) -> Color {
        if !hasTasks { return .clear }
        return isSelected ? .orange : .secondary
    }
    
    // MARK: - Tasks for the selected day
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.subheadline.weight(.semibold))
                
                Spacer()
                
                if !tasksForSelectedDate.isEmpty {
                    Text("\(tasksForSelectedDate.count) \(tasksForSelectedDate.count == 1 ? "Task" : "Tasks")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            if tasksForSelectedDate.isEmpty {
                ContentUnavailableView(
                    "Nothing Scheduled",
                    systemImage: "calendar",
                    description: Text("No Tasks are due on this day.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(tasksForSelectedDate) { task in
                            ScheduledTaskRow(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Scheduled task row
struct ScheduledTaskRow: View {
    @Environment(Supabase.self) var db
    @Environment(\.colorScheme) private var colorScheme
    let task: ToDoTask
    private let cornerRadius: CGFloat = 12
    private var list: List? {
        db.lists.first(where: { $0.id == task.listID })
    }
    private var collection: Collection? {
        db.collections.first(where: { $0.id == task.collectionID })
    }
    private var accent: Color {
        list?.bgColor ?? Color.secondary
    }
    private var isOverdue: Bool {
        guard let schedule = task.schedule else { return false }
        return schedule < Date()
    }
    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(task.text)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                
                Spacer(minLength: 8)
                
                if let schedule = task.schedule {
                    Text(schedule.formatted(date: .omitted, time: .shortened))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isOverdue ? Color.red : Color.secondary)
                }
            }
            
            if let description = task.description, !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            locationLabel
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .background(
            cardShape.fill(
                colorScheme == .dark
                ? Color(.secondarySystemGroupedBackground)
                : Color.white
            )
        )
        .overlay {
            cardShape.strokeBorder(accent.opacity(0.25), lineWidth: 0.8)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accent)
                .frame(width: 3)
        }
        .clipShape(cardShape)
    }
    
    // MARK: - List and Collection
    private var locationLabel: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
            
            if let list {
                Text(list.listName)
                    .lineLimit(1)
            }
            
            if let collection {
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
                
                Text(collection.collectionName)
                    .lineLimit(1)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    ScheduledView()
}
