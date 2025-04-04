//
//  NavigationBackButton.swift
//  List It
//
//  Created by Abdul Moiz on 04/04/2025.
//

import SwiftUI

struct NavigationBackButton: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(colorScheme == .light ? .black : .white)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
}

#Preview {
    NavigationBackButton()
}
