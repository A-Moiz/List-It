//
//  TomorrowHeaderView.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct TomorrowHeaderView: View {
    // MARK: - Properties
    let totalTasks: Int
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack {
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                    Text(tomorrow.formatted(.dateTime.weekday(.wide).month().day()))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.1)
                                    : Color.black.opacity(0.06),
                                lineWidth: 4
                            )
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(totalTasks)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

//#Preview {
//    TomorrowHeaderView()
//}
