//
//  Collection.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import Foundation
import SwiftUI

struct Collection: Identifiable {
    var id: String
    var collectionName: String
    var bgColorHex: String
    var dateCreated: Date
    var tasks: [Task] = []
    var notes: [Note] = []
    var bgColor: Color {
        Color(hex: bgColorHex)
    }
}
