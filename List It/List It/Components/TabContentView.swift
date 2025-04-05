//
//  TabContentView.swift
//  List It
//
//  Created by Abdul Moiz on 05/04/2025.
//

import SwiftUI

struct TabContentView: View {
    @Binding var selectedTab: Tab
    @Binding var tabProgress: CGFloat
    private var scrollPositionBinding: Binding<Tab?> {
        Binding<Tab?>(
            get: { selectedTab },
            set: { newValue in
                if let newTab = newValue {
                    selectedTab = newTab
                }
            }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    Text("Tasks")
                        .id(Tab.task)
                        .containerRelativeFrame(.horizontal)
                    
                    Text("Notes")
                        .id(Tab.note)
                        .containerRelativeFrame(.horizontal)
                }
                .scrollTargetLayout()
                .offsetX { value in
                    let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
                    tabProgress = max(min(progress, 1), 0)
                }
            }
            .scrollPosition(id: scrollPositionBinding)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tab = .task
    @Previewable @State var tabProgress: CGFloat = 0
    TabContentView(selectedTab: $selectedTab, tabProgress: $tabProgress)
}
