//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct CollectionView: View {
    var collectionIcon: String
    var fillColor: Color
    var collectionName: String
    var contentCount: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(fillColor)
                .frame(height: 120)
                .shadow(radius: 10)
            
            HStack(spacing: 15) {
                if collectionIcon.isEmpty {
                    Image("checklist-2")
                        .resizable()
                        .frame(width: 60, height: 60)
                } else {
                    Image(systemName: collectionIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(collectionName.capitalized)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("\(contentCount) Items")
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
    @Previewable @State var collectionIcon: String = ""
    @Previewable @State var fillColor: Color = .blue
    @Previewable @State var collectionName: String = "my collection"
    @Previewable @State var contentCount: Int = 12
    CollectionView(collectionIcon: "gamecontroller", fillColor: fillColor, collectionName: collectionName, contentCount: contentCount)
}
