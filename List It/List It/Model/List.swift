//
//  Collection.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import Foundation
import SwiftUI

struct List: Codable, Identifiable {
    var id: String
    var createdAt: Date
    var listIcon: String
    var listName: String
    var isDefault: Bool
    var bgColorHex: String
    var userId: String

    var bgColor: Color {
        Color(hex: bgColorHex)
    }

    var isPinned: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case listIcon = "list_icon"
        case listName = "list_name"
        case isDefault = "is_default"
        case bgColorHex = "bg_color_hex"
        case isPinned = "is_pinned"
        case userId = "user_id"
    }
}
