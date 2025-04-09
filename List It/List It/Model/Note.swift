//
//  Note.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import Foundation
import SwiftUI

struct Note: Identifiable {
    var id: String
    var title: String
    var description: String
    var dateCreated: Date
    var isDeleted: Bool
    var bgColorHex: String
    var isPinned: Bool
    var bgColor: Color {
        Color(hex: bgColorHex)
    }
}
