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
    let fullName: String
    let email: String
    let lists: [List]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case fullName = "full_name"
        case email
        case lists
    }

    init(id: UUID, createdAt: Date? = nil, fullName: String, email: String, lists: [List]) {
        self.id = id
        self.createdAt = createdAt
        self.fullName = fullName
        self.email = email
        self.lists = lists
    }
}
