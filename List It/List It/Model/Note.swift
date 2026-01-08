//
//  Note.swift
//  List It
//
//  Created by Abdul Moiz on 07/01/2026.
//

import Foundation
import SwiftUI

struct Note: Codable, Identifiable {
    var id: String
    @SupabaseDate
    var createdAt: Date
    var title: String
    var description: String?
    var isDeleted: Bool
    var bgColorHex: String
    var isPinned: Bool
    var collectionID: String
    var userID: String
    var listID: String
    
    var bgColor: Color {
        Color(hex: bgColorHex)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case title
        case description
        case isDeleted = "is_deleted"
        case bgColorHex = "bg_color_hex"
        case isPinned = "is_pinned"
        case collectionID = "collection_id"
        case userID = "user_id"
        case listID = "list_id"
    }
}
