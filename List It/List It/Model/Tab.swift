//
//  Tab.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import Foundation

enum Tab: String, CaseIterable, Hashable {
    case task = "Task"
    case note = "Note"
    
    var systemImage: String {
        switch self {
        case .task:
            return "list.dash"
        case .note:
            return "square.and.pencil"
        }
    }
}
