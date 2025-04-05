//
//  Task.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import Foundation

struct Task {
    var id: String
    var text: String
    var description: String?
    var dateCreated: Date
    var dueDate: Date?
    var isCompleted: Bool
    var dateCompleted: Date?
    var isDeleted: Bool
    var isPinned: Bool
}
