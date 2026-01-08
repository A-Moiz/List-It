//
//  SupabaseDate.swift
//  List It
//
//  Created by Abdul Moiz on 05/01/2026.
//

import Foundation

@propertyWrapper
struct SupabaseDate: Codable {
    var wrappedValue: Date
    init(wrappedValue: Date) { self.wrappedValue = wrappedValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss",     // Old app format
            "yyyy-MM-dd HH:mm:ss",       // New app format
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Supabase standard timestamptz
        ]
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                self.wrappedValue = date
                return
            }
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        try container.encode(df.string(from: wrappedValue))
    }
}

