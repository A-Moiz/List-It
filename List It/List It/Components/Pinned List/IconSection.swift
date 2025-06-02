//
//  IconSection.swift
//  List It
//
//  Created by Abdul Moiz on 29/05/2025.
//

import SwiftUI

struct IconSection: View {
    // MARK: - Properties
    @Binding var list: List
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(list.bgColor.opacity(0.15))
                    .frame(width: 70, height: 70)
                Circle()
                    .fill(LinearGradient(colors: [
                        list.bgColor.opacity(0.8),
                        list.bgColor.opacity(0.6)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .frame(width: 56, height: 56)
                Image(systemName: list.isDefault ? list.listIcon : "checklist")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(1.0)
            
            Text(list.listName.capitalized)
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)
        }
        .padding(.top, 40)
    }
}

//#Preview {
//    IconSection()
//}
