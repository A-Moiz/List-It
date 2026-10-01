//
//  ContentView.swift
//  List It
//
//  Created by Abdul Moiz on 02/01/2026.
//

import SwiftUI

struct IntroView: View {
    @State private var currentStep: Int = 0
    @State private var animateContent: Bool = false
    @State private var goToSignUp: Bool = false
    private var lastStep = 3
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                TabView(selection: $currentStep) {
                    listsStepCard
                        .tag(0)
                    
                    collectionsStepCard
                        .tag(1)
                    
                    tasksAndNotesStepCard
                        .tag(2)
                    
                    getStartedStepCard
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .ignoresSafeArea()
                .opacity(animateContent ? 1.0 : 0.0)
                .scaleEffect(animateContent ? 1.0 : 0.88)
                .offset(y: animateContent ? 0 : 350)
            }
            .background(Color(uiColor: .secondarySystemBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if currentStep != lastStep {
                        Button("Skip") {
                            goToSignUp = true
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                    }
                }
            }
            .navigationDestination(isPresented: $goToSignUp) {
                SignUpView()
            }
            .onAppear {
                triggerLaunchAnimation()
            }
        }
    }
    
    // MARK: - Animation Controller
    func triggerLaunchAnimation() {
        withAnimation(.spring(response: 0.85, dampingFraction: 0.72, blendDuration: 0).delay(0.1)) {
            animateContent = true
        }
    }
    
    // MARK: - Card 1
    @ViewBuilder
    private var listsStepCard: some View {
        OnboardingFullScreenView(imageName: "tray.full.fill", title: "Start with a List", accentColor: .blue) {
            VStack(spacing: 20) {
                Text("Lists are your top-level spaces - the big areas of your life you want to keep organised.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("School", systemImage: "tray.fill")
                    Label("Work", systemImage: "tray.fill")
                    Label("Home", systemImage: "tray.fill")
                    Label("Entertainment", systemImage: "tray.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Card 2
    @ViewBuilder
    private var collectionsStepCard: some View {
        OnboardingFullScreenView(
            imageName: "folder.badge.gearshape",
            title: "Break it down with Collections",
            accentColor: .purple
        ) {
            VStack(spacing: 20) {
                Text("Inside each List, Collections group the Tasks and Notes that belong together.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("School", systemImage: "tray.fill")
                        .font(.subheadline.weight(.semibold))
                    VStack(alignment: .leading, spacing: 6) {
                        Label("General", systemImage: "folder.fill")
                        Label("Maths", systemImage: "folder.fill")
                        Label("Science", systemImage: "folder.fill")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.purple.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text("Every new List starts with a General Collection, ready to use.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Card 3
    @ViewBuilder
    private var tasksAndNotesStepCard: some View {
        OnboardingFullScreenView(
            imageName: "checklist",
            title: "Tasks to do, notes to remember",
            accentColor: .green
        ) {
            VStack(spacing: 20) {
                Text("Add a Task as a reminder, or a Note to hold on to something - both live right in the Collection they belong to.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Complete Maths homework", systemImage: "checkmark.circle")
                    Label("Quadratic formula: x = (-b ± √(b²-4ac)) / 2a", systemImage: "note.text")
                }
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.85))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Card 4
    @ViewBuilder
    private var getStartedStepCard: some View {
        OnboardingFullScreenView(
            imageName: "sparkles",
            title: "You're ready to get organised",
            accentColor: .indigo
        ) {
            VStack(spacing: 24) {
                Text("Create your first List and start grouping your Tasks and Notes into Collections.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Button {
                    goToSignUp = true
                } label: {
                    ButtonView(buttonTxt: "Get Started", showArrow: true)
                }
            }
        }
    }
}

// MARK: - Full Screen Onboarding Container with Cascade Animation
struct OnboardingFullScreenView<Content: View>: View {
    let imageName: String
    let title: String
    let accentColor: Color
    let content: () -> Content
    @State private var revealItems: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // 1. App name
                    Text("LIST IT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary.opacity(0.6))
                        .tracking(2)
                        .padding(.top, 40)
                        .opacity(revealItems ? 1.0 : 0.0)
                        .offset(y: revealItems ? 0 : -30)
                    
                    Spacer(minLength: 40)
                    
                    // 2. Main Icon
                    Image(systemName: imageName)
                        .font(.system(size: 76))
                        .foregroundColor(accentColor)
                        .padding(.bottom, 24)
                        .scaleEffect(revealItems ? 1.0 : 0.2)
                        .rotationEffect(.degrees(revealItems ? 0 : -45))
                        .opacity(revealItems ? 1.0 : 0.0)
                    
                    // 3. Title
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                        .padding(.horizontal, 20)
                        .opacity(revealItems ? 1.0 : 0.0)
                        .offset(y: revealItems ? 0 : 30)
                    
                    // 4. Step Content
                    content()
                        .padding(.horizontal, 24)
                        .opacity(revealItems ? 1.0 : 0.0)
                        .offset(y: revealItems ? 0 : 40)
                    
                    Spacer(minLength: 80)
                }
                .frame(minHeight: max(0, proxy.size.height - 100))
            }
            .background(Color(uiColor: .secondarySystemBackground).ignoresSafeArea())
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 70, damping: 11).delay(0.35)) {
                    revealItems = true
                }
            }
        }
    }
}

#Preview {
    IntroView()
        .environment(Supabase())
}
