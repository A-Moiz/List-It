//
//  Collection.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import Foundation
import SwiftUI

struct List {
    var id: String
    var listName: String
    var bgColorHex: String
    var dateCreated: Date
    var isDefault: Bool
    var contentCount: Int {
        (tasks?.count ?? 0) + (notes?.count ?? 0)
    }
    var tasks: [Task]?
    var notes: [Note]?
    var collections: [Collection]?
    var bgColor: Color {
        Color(hex: bgColorHex)
    }
}
