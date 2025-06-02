//
//  InsightRow.swift
//  List It
//
//  Created by Abdul Moiz on 31/05/2025.
//

import SwiftUI

struct InsightRow: View {
    // MARK: - Properties
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}
