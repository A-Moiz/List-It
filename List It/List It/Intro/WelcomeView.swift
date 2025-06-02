//
//  WelcomeView.swift
//  List It
//
//  Created by Abdul Moiz on 31/03/2025.
//

import SwiftUI

struct WelcomeView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var showContent = false
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Dynamic Background
                backgroundGradient
                    .ignoresSafeArea()
                
                // MARK: - Floating Shapes
                floatingShapes
                
                // MARK: - Main Content
                VStack(spacing: 0) {
                    Spacer()
                    
                    // MARK: - App Icon Section
                    appIconSection
                        .offset(y: showContent ? 0 : -50)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    // MARK: - Title Section
                    titleSection
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showContent)
                    
                    Spacer()
                    
                    // MARK: - Action Button
                    actionButton
                        .offset(y: showContent ? 0 : 50)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showContent)
                    
                    // MARK: - Bottom Spacing
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, 32)
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                showContent = true
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "87CEEB"),
                Color(hex: "4682B4"),
                Color(hex: "1E3A8A")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Floating Shapes
    private var floatingShapes: some View {
        ZStack {
            // MARK: - Large circle - top right
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200)
                .offset(x: 150, y: -200)
                .blur(radius: 1)
            
            // MARK: - Medium circle - bottom left
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 150)
                .offset(x: -120, y: 300)
                .blur(radius: 2)
            
            // MARK: - Small circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 80)
                .offset(x: -150, y: -100)
            
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 60)
                .offset(x: 130, y: 200)
        }
    }
    
    // MARK: - App Icon Section
    private var appIconSection: some View {
        VStack(spacing: 24) {
            ZStack {
                // MARK: - Glow effect
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .blur(radius: 20)
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                
                // MARK: - App icon container
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .overlay {
                        Image("app-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            }
            .onAppear {
                pulseAnimation = true
            }
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Plan,")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Prioritise,")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("Produce")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .multilineTextAlignment(.center)
            
            Text("Transform your ideas into achievements with seamless planning and organization")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, 20)
        }
        .padding(.top, 40)
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        NavigationLink(destination: SignUpView(db: db, helper: helper)) {
            HStack(spacing: 12) {
                Text("Get Started")
                    .font(.system(size: 20, weight: .semibold))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)
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
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .scaleEffect(showContent ? 1.0 : 0.9)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showContent)
        }
        .buttonStyle(PressedButtonStyle())
    }
}

//#Preview {
//    WelcomeView(db: Supabase(), helper: Helper())
//}
