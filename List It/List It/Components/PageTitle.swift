//
//  PageTitle.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI

struct PageTitle: View {
    @State var textOne: String
    @State var textTwo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(textOne)
                .font(.system(size: 38, weight: .bold, design: .rounded))
            
            Text(textTwo)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    PageTitle(textOne: "", textTwo: "")
}
