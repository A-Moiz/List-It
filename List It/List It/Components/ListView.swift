//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct ListView: View {
    var list: List
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(list.bgColor)
                .frame(height: 90)
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
            
            HStack(spacing: 15) {
                Image(systemName: "checklist")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(list.listName.description.capitalized)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("\(list.contentCount) Items")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listName: "Today", bgColorHex: "#87CEEB", dateCreated: Date(), isDefault: true, tasks: [], notes: [], collections: [])
    ListView(list: list)
}
