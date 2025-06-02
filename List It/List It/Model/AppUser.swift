//
//  AppUser.swift
//  List It
//
//  Created by Abdul Moiz on 29/04/2025.
//

import Foundation

struct AppUser: Codable, Identifiable {
    let id: UUID
    let createdAt: Date?
    var fullName: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case fullName = "full_name"
        case email
    }

    init(id: UUID, createdAt: Date? = nil, fullName: String, email: String) {
        self.id = id
        self.createdAt = createdAt
        self.fullName = fullName
        self.email = email
    }
}
