//
//  OverdueHeader.swift
//  List It
//
//  Created by Abdul Moiz on 26/05/2025.
//

import SwiftUI

struct OverdueHeader: View {
    // MARK: - Properties
    let totalTasks: Int
    
    var body: some View {
        HStack {
            // MARK: - Alert banner
            HStack(spacing: 12) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
                Text("These tasks require immediate attention")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            
            ZStack {
                // MARK: - Total tasks
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(totalTasks)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
        }
    }
}

//#Preview {
//    OverdueHeader()
//}
