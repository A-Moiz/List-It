//
//  TabBar.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Tab
    var tabProgress: CGFloat
    
    var body: some View {
        /// Rectangle Design
        //        HStack(spacing: 0) {
        //            ForEach(Tab.allCases, id: \.rawValue) { tab in
        //                HStack(spacing: 10) {
        //                    Image(systemName: tab.systemImage)
        //
        //                    Text(tab.rawValue)
        //                        .font(.callout)
        //                }
        //                .frame(maxWidth: .infinity)
        //                .padding(.vertical, 10)
        //                .contentShape(Rectangle())
        //                .onTapGesture {
        //                    withAnimation(.snappy) {
        //                        selectedTab = tab
        //                    }
        //                }
        //            }
        //        }
        //        .tabMask(tabProgress)
        //        .background {
        //            GeometryReader {
        //                let size = $0.size
        //                let capsuleWidth = size.width / CGFloat(Tab.allCases.count)
        //
        //                RoundedRectangle(cornerRadius: 10)
        //                    .fill(Color.gray.opacity(0.5))
        //                    .frame(width: capsuleWidth)
        //                    .offset(x: tabProgress * (size.width - capsuleWidth))
        //            }
        //        }
        //        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        //        .padding(.horizontal, 15)
        
        /// Capsule Design
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                HStack(spacing: 10) {
                    Image(systemName: tab.systemImage)
                    
                    Text(tab.rawValue)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(.capsule)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selectedTab = tab
                    }
                }
            }
        }
        .tabMask(tabProgress)
        .background {
            GeometryReader {
                let size = $0.size
                let capsuleWidth = size.width / CGFloat(Tab.allCases.count)
                
                Capsule()
                    .fill(.gray.opacity(0.5))
                    .frame(width: capsuleWidth)
                    .offset(x: tabProgress * (size.width - capsuleWidth))
            }
        }
        .background(.gray.opacity(0.1), in: .capsule)
        .padding(.horizontal, 15)
    }
}

#Preview {
    @Previewable @State var selectedTab: Tab = .task
    @Previewable @State var tabProgress: CGFloat = 0
    TabBar(selectedTab: $selectedTab, tabProgress: tabProgress)
}
