//
//  AppColor.swift
//  List It
//
//  Created by Abdul Moiz on 25/03/2026.
//

import Foundation

struct AppColor: Decodable, Identifiable {
    let id: Int
    let createdAt: Date
    let colorHex: String
    let colorName: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case colorHex = "color_hex"
        case colorName = "color_name"
    }
}
