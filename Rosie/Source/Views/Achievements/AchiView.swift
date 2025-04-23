//
//  AchiView.swift
//  Rosie
//
//  Created by Alex on 30.03.2025.
//

import SwiftUI

struct AchiView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var achievementManager = AchievementManager.shared
    
    // Grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Image(.bgimg)
                .resizable()
                .ignoresSafeArea()
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                // Header with back button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(.back)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                }
                .padding([.horizontal, .top])
                
                // Grid of achievements
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(Achievement.allCases) { achievement in
                        AchievementItemView(
                            achievement: achievement,
                            isUnlocked: achievementManager.hasUnlocked(achievement)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    // Animation states
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Achievement image
            Image(achievement.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .opacity(isUnlocked ? 1.0 : 0.6)
            
            // Unlocked indicator
            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            rotation = 360
                            scale = 1
                        }
                    }
            }
        }
    }
}

#Preview {
    AchiView()
}

struct AchievementNotificationView: View {
    var body: some View {
        Text("New achievement!")
            .myfont2(16)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.yellow, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 3)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
