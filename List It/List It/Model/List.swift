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
    var type: ListType
    var collections: [Collection]
    var tasks: [Task]?
    var bgColor: Color {
        Color(hex: bgColorHex)
    }
}
