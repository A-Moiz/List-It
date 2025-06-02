//
//  emptyStateView.swift
//  List It
//
//  Created by Abdul Moiz on 02/05/2025.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    let icon: String
    let collectionColor: Color
    let message: String
    let subMessage: String
    
    // MARK: - Empty view if no Tasks/Notes
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(collectionColor.opacity(0.6))
                .padding(.bottom, 8)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Text(subMessage)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    EmptyStateView(icon: "", collectionColor: .orange, message: "", subMessage: "")
}
