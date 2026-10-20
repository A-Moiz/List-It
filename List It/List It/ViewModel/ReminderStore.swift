//
//  ReminderStore.swift
//  List It
//
//  Created by Abdul Moiz on 18/10/2026.
//

import Foundation
import Observation

@Observable
final class ReminderStore {
    static let shared = ReminderStore()
    private static let key = "taskReminderTimes"
    
    private var times: [String: Double] = [:]
    
    private init() {
        times = UserDefaults.standard.dictionary(forKey: Self.key) as? [String: Double] ?? [:]
    }
    
    static func date(for taskID: String) -> Date? {
        shared.times[taskID].map { Date(timeIntervalSince1970: $0) }
    }
    
    static func set(_ date: Date, for taskID: String) {
        DispatchQueue.main.async {
            shared.times[taskID] = date.timeIntervalSince1970
            shared.save()
        }
    }
    
    static func remove(for taskID: String) {
        DispatchQueue.main.async {
            shared.times[taskID] = nil
            shared.save()
        }
    }
    
    private func save() {
        UserDefaults.standard.set(times, forKey: Self.key)
    }
}
