//
//  MetaDataRow.swift
//  List It
//
//  Created by Abdul Moiz on 02/06/2025.
//

import SwiftUI

struct MetaDataRow: View {
    // MARK: - Properties
    @State var title: String
    @State var value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
