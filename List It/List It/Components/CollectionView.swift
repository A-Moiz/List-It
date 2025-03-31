//
//  CollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

//struct CollectionView: View {
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color.red)
//                .frame(width: 175, height: 150)
//                .shadow(radius: 10)
//            
//            Text("Hello, World!")
//                .font(.title)
//                .bold()
//                .foregroundStyle(.white)
//                .multilineTextAlignment(.center)
//                .padding()
//                .frame(width: 100, height: 100)
//                .minimumScaleFactor(0.5)
//                .lineLimit(4)
//        }
//    }
//}

//struct CollectionView: View {
//    var body: some View {
//        ZStack {
//            // Gradient background with a soft blur for a modern look
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial) // Glassmorphism effect
//                .background(
//                    LinearGradient(colors: [Color.orange.opacity(0.7), Color.red.opacity(0.7)],
//                                   startPoint: .topLeading,
//                                   endPoint: .bottomTrailing)
//                )
//                .blur(radius: 2)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
//                .frame(height: 170)
//                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
//
//            VStack(spacing: 10) {
//                Image(systemName: "folder.fill")
//                    .font(.system(size: 45))
//                    .foregroundColor(.white.opacity(0.9))
//                    .shadow(radius: 2)
//
//                Text("Collection Name")
//                    .font(.title3)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text("12 Items")
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            .padding()
//            .multilineTextAlignment(.center)
//        }
//        .padding(5)
//        .onTapGesture {
//            // Add animation or navigation action
//        }
//    }
//}

struct CollectionView: View {
    var body: some View {
        ZStack {
            // Glassmorphism background with gradient overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial) // Glass effect
                .background(
                    LinearGradient(colors: [Color.orange.opacity(0.7), Color.red.opacity(0.7)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .blur(radius: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .frame(height: 120) // Wider and shorter shape
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

            HStack(spacing: 15) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(radius: 2)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Collection Name")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    Text("12 Items")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 5)
        .onTapGesture {
            // Add navigation or interaction
        }
    }
}

#Preview {
    CollectionView()
}
