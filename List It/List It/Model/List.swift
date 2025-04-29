//
//  Collection.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import Foundation
import SwiftUI

//struct List {
//    var id: String
//    var listIcon: String
//    var listName: String
//    var isDefault: Bool
//    var bgColorHex: String
//    var dateCreated: Date
//    var type: ListType
//    var collections: [Collection]
//    var tasks: [ToDoTask]?
//    var bgColor: Color {
//        Color(hex: bgColorHex)
//    }
//    var isPinned: Bool
//}

struct List: Codable {
    var id: String
    var listIcon: String
    var listName: String
    var isDefault: Bool
    var bgColorHex: String
    var dateCreated: Date
    var collections: [Collection]
    var tasks: [ToDoTask]?

    var bgColor: Color {
        Color(hex: bgColorHex)
    }

    var isPinned: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case listIcon = "list_icon"
        case listName = "list_name"
        case isDefault = "is_default"
        case bgColorHex = "bg_color_hex"
        case dateCreated = "date_created"
        case collections
        case tasks
        case isPinned = "is_pinned"
    }
}
