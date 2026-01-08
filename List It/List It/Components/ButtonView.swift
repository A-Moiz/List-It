//
//  ButtonView.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI

struct ButtonView: View {
    var buttonTxt: String
    var showArrow: Bool
    
    var body: some View {
        HStack {
            Text(buttonTxt)
            if showArrow {
                Image(systemName: "arrow.right")
            }
        }
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.orange, Color.orange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: 8)
        }
    }
}

#Preview {
    ButtonView(buttonTxt: "", showArrow: false)
}
