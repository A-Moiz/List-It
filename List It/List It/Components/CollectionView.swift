//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct CollectionView: View {
    var collection: Collection
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(collection.bgColor)
                .frame(height: 90)
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
            
            HStack(spacing: 15) {
                Image(systemName: "checklist")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(collection.collectionName.capitalized)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("\(collection.contentCount) Items")
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
    @Previewable @State var collection = Collection(id: NSUUID().uuidString, collectionName: "Today", bgColor: .orange, dateCreated: Date(), isDefault: true)
    CollectionView(collection: collection)
}
