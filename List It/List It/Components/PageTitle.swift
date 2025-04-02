//
//  PageTitle.swift
//  List It
//
//  Created by Abdul Moiz on 03/04/2025.
//

import SwiftUI

struct PageTitle: View {
    @State var textOne: String
    @State var textTwo: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(textOne)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(AppConstants.colorScheme == .dark ? .white : .primary)
            Text(textTwo)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(AppConstants.accentColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    PageTitle(textOne: "Create", textTwo: "Account")
}
