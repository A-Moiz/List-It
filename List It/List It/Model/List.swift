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
    var collections: [Collection]
    var bgColor: Color {
        Color(hex: bgColorHex)
    }
}
