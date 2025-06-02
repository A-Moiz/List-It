//
//  CompletedTimelineView.swift
//  List It
//
//  Created by Abdul Moiz on 24/05/2025.
//

import SwiftUI

struct CompletedTimelineView: View {
    // MARK: - Properties
    let isLastInGroup: Bool
    let isLastGroup: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.green.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 20)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 16, height: 16)
                    .shadow(color: .green.opacity(0.4), radius: 3, x: 0, y: 1)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
            }

            if !isLastInGroup || !isLastGroup {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.6), isLastInGroup ? .clear : Color.green.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
                    .frame(minHeight: isLastInGroup ? 30 : 60)
            }
        }
        .padding(.trailing, 20)
    }
}

//#Preview {
//    CompletedTimelineView()
//}
