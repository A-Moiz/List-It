//
//  Collection.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import Foundation
import SwiftUI

struct Collection {
    var id: String
    var collectionName: String
    var bgColor: Color
    var dateCreated: Date
    var isDefault: Bool
    var contentCount: Int {
        (tasks?.count ?? 0) + (notes?.count ?? 0)
    }
    var tasks: [Task]?
    var notes: [Note]?
}
