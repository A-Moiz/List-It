//
//  ToDoTask.swift
//  List It
//
//  Created by Abdul Moiz on 06/01/2026.
//

import Foundation

struct ToDoTask: Codable, Identifiable {
    var id: String
    @SupabaseDate
    var createdAt: Date
    var text: String
    var description: String?
    var dueDate: Date?
    var isCompleted: Bool
    var dateCompleted: Date?
    var isDeleted: Bool
    var isPinned: Bool
    var userID: String
    var collectionID: String
    var listID: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case text
        case description
        case dueDate = "due_date"
        case isCompleted = "is_completed"
        case dateCompleted = "date_completed"
        case isDeleted = "is_deleted"
        case isPinned = "is_pinned"
        case userID = "user_id"
        case collectionID = "collection_id"
        case listID = "list_id"
    }
}
