//
//  TabButton.swift
//  List It
//
//  Created by Abdul Moiz on 04/05/2025.
//

import SwiftUI

struct TabButton: View {
    // MARK: - Properties
    let tab: Tab
    @Binding var selectedTab: Tab
    var namespace: Namespace.ID
    let collectionColor: Color
    
    // MARK: - Tab selection button view
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                // MARK: - Image and text based on selected tab
                HStack(spacing: 6) {
                    Image(systemName: tab == .task ? "checklist" : "note.text")
                        .font(.system(size: 13))
                    
                    Text(tab == .task ? "Tasks" : "Notes")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(selectedTab == tab ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(collectionColor.opacity(0.5))
                                .matchedGeometryEffect(id: "TAB", in: namespace)
                        }
                    }
                )
            }
        }
    }
}

//#Preview {
//    TabButton()
//}
