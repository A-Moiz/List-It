//
//  ToggleRow.swift
//  List It
//
//  Created by Abdul Moiz on 02/06/2025.
//

import SwiftUI

struct ToggleRow: View {
    // MARK: - Properties
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
        }
        .padding(.vertical, 4)
    }
}

//#Preview {
//    ToggleRow()
//}
