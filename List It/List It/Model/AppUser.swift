//
//  AppUser.swift
//  List It
//
//  Created by Abdul Moiz on 04/01/2026.
//

import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    let createdAt: Date?
    var name: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case name = "full_name"
        case email
    }

    init(id: String, createdAt: Date? = nil, name: String, email: String) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.email = email
    }
}
