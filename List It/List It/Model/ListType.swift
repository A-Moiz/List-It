//
//  ListType.swift
//  List It
//
//  Created by Abdul Moiz on 15/04/2025.
//

import Foundation

enum ListType {
    case regular
    case completed([Task])
    case notCompleted([Task])
}
