//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct ListView: View {
    @Binding var list: List
    @ObservedObject var helper: Helper
    @ObservedObject var db: Supabase
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: ListDetailView(list: $list, helper: helper, db: db)) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(list.bgColor)
                    .frame(height: 90)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
                
                HStack(spacing: 15) {
                    if list.isDefault {
                        Image(systemName: list.listIcon)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.black)
                    } else {
                        Image(systemName: "checklist")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.black)
                    }
                        
                    VStack(alignment: .leading, spacing: 5) {
                        Text(list.listName.description.capitalized)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var list = List(id: UUID().uuidString, listIcon: "calendar", listName: "Today", isDefault: true, bgColorHex: "#87CEEB", dateCreated: Date(), type: .regular, collections: [])
    ListView(list: $list, helper: Helper(), db: Supabase())
}
