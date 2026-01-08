//
//  ContentView.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI

struct IntroView: View {
    @State private var goToSignup: Bool = false
    @Environment(Supabase.self) var db
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "87CEEB"), Color(hex: "4682B4"), Color(hex: "1E3A8A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                BackgroundShapes()

                VStack {
                    Spacer()
                    
                    IconView()
                    
                    IntroText()
                    
                    Spacer()
                    
                    Button {
                        goToSignup = true
                    } label: {
                        ButtonView(buttonTxt: "Get Started", showArrow: true)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
            .navigationDestination(isPresented: $goToSignup) {
                SignUpView(db: _db)
            }
        }
    }
}

// MARK: - Background design
struct BackgroundShapes: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200)
                .offset(x: 150, y: -200)
                .blur(radius: 1)
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 150)
                .offset(x: -120, y: 300)
                .blur(radius: 2)
            
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
}

// MARK: - App icon view
struct IconView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .blur(radius: 20)
                
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
        }
    }
}

// MARK: - Intro text view
struct IntroText: View {
    var body: some View {
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
            
            Text("Transform your ideas into achievements with seamless planning and organisation")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, 20)
        }
        .padding(.top, 40)
    }
}

#Preview {
    IntroView()
        .environment(Supabase())
}
