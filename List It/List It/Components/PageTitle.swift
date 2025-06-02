//
//  PageTitle.swift
//  List It
//
//  Created by Abdul Moiz on 03/04/2025.
//

import SwiftUI

struct PageTitle: View {
    // MARK: - Properties
    @State var textOne: String
    @State var textTwo: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(textOne)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            Text(textTwo)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(AppConstants.accentColor(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    PageTitle(textOne: "Create", textTwo: "Account")
}
