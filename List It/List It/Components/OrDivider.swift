//
//  OrDivider.swift
//  List It
//
//  Created by Abdul Moiz on 03/04/2025.
//

import SwiftUI

struct OrDivider: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text("OR")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.7) : .gray)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
}

#Preview {
    OrDivider()
}
