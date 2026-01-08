//
//  Collection.swift
//  List It
//
//  Created by Abdul Moiz on 05/01/2026.
//

import Foundation
import SwiftUI

struct Collection: Codable, Identifiable {
    let id: String
    @SupabaseDate
    var createdAt: Date
    var collectionName: String
    var bgColorHex: String
    var listID: String
    var userID: String

    var bgColor: Color {
        Color(hex: bgColorHex)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case collectionName = "collection_name"
        case bgColorHex = "bg_color_hex"
        case listID = "list_id"
        case userID = "user_id"
    }
}
