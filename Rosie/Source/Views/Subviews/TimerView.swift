//
//  TimerView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

struct TimerView: View {
    @Binding var timeRemaining: TimeInterval
    let totalTime: TimeInterval
    
    // Reward bindings
    @Binding var recentTimeReward: (seconds: Double, reason: String)?
    @Binding var showTimeRewardAnimation: Bool
    
    // Animation properties
    @State private var isWarning: Bool = false
    @State private var scaleEffect: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 4) {
            // Time text
            HStack {
                Text(timeFormatted)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(timeColor)
                    .scaleEffect(scaleEffect)
                    .onChange(of: showTimeRewardAnimation) { show in
                        if show {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                scaleEffect = 1.2
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring()) {
                                    scaleEffect = 1.0
                                }
                            }
                        }
                    }
                
                // Time reward indicator
                if let reward = recentTimeReward, showTimeRewardAnimation {
                    Text("+\(String(format: "%.1fs", reward.seconds))")
                        .font(.system(size: 16, weight: .heavy, design: .serif))
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Reward reason text
//            if let reward = recentTimeReward, showTimeRewardAnimation {
//                Text(reward.reason)
//                    .font(.system(size: 14, weight: .bold, design: .rounded))
//                    .foregroundColor(.white.opacity(0.9))
//                    .padding(.top, 4)
//                    .transition(.opacity)
//            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: timeColor.opacity(0.5), radius: 5)
        )
        .onChange(of: timeRemaining) { newValue in
            // Update warning state when time is low (less than 10 seconds)
            withAnimation {
                isWarning = newValue < 10
            }
        }
    }
    
    // Formatted time string (MM:SS)
    private var timeFormatted: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Color based on remaining time
    private var timeColor: Color {
        if timeRemaining < 5 {
            return .red
        } else if timeRemaining < 10 {
            return .orange
        } else {
            return .white
        }
    }
}

#Preview {
    ZStack {
        Image(.bgimg)
        TimerView(
            timeRemaining: .constant(TimeInterval(13)),
            totalTime: TimeInterval(30),
            recentTimeReward: .constant((seconds: 2.5, reason: "Combo x2.5")),
            showTimeRewardAnimation: .constant(true)
        )
    }
}
