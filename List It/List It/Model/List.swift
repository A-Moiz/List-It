//
//  List.swift
//  List It
//
//  Created by Abdul Moiz on 04/01/2026.
//

import Foundation
import SwiftUI

struct List: Codable, Identifiable, Hashable {
    let id: String
    @SupabaseDate
    var createdAt: Date
    var listIcon: String
    var listName: String
    let isDefault: Bool
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
    // Hashable conformance for NavigationStack destinations
    static func == (lhs: List, rhs: List) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
