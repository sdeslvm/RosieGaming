//
//  GameOverView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

struct GameOverView: View {
    // MARK: - Properties
    
    @Binding var isShowing: Bool
    let score: Int
    let gameMode: GameMode
    let restartAction: () -> Void
    let returnToMenuAction: () -> Void
    
    // High score from UserDefaults
    @State private var highScore: Int = 0
    @State private var isNewHighScore: Bool = false
    
    // Animation properties
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Text("GAME OVER")
                        .myfont2(28)
                        .colorMultiply(.red)
                    
                    if isNewHighScore {
                        Text("New High Score!")
                            .myfont2(16)
                            .colorMultiply(.yellow)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.yellow.opacity(0.2))
                            )
                    }
                }
                
                // Score information
                VStack(spacing: 15) {
                    HStack {
                        Text("Score:")
                            .myfont(22)
                        Spacer()
                        Text("\(score)")
                            .myfont2(22)
                    }
                    
                    HStack {
                        Text("Best Score:")
                            .myfont(22)
                        Spacer()
                        Text("\(highScore)")
                            .myfont2(22)
                            .colorMultiply(isNewHighScore ? .yellow : .white)
                    }
                }
                
                // Buttons
                VStack(spacing: 20) {
                    Button {
                        restartAction()
                    } label: {
                        Image(.ellipse)
                            .resizable()
                            .frame(width: 200, height: 50)
                            .overlay {
                                Text("RESTART")
                                    .myfont2(26)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        returnToMenuAction()
                    } label: {
                        Image(.ellipse)
                            .resizable()
                            .frame(width: 200, height: 50)
                            .overlay {
                                Text("MENU")
                                    .myfont2(26)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: 350)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                // Check if this is a new high score
                checkHighScore()
                
                // Animate in
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 1
                    scale = 1
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkHighScore() {
        highScore = UserDefaults.standard.integer(forKey: gameMode.leadersKey)
        isNewHighScore = score > highScore
        
        // If it's a new high score, save it
        if isNewHighScore {
            UserDefaults.standard.set(score, forKey: gameMode.leadersKey)
        }
    }
}

#Preview {
    GameOverView(isShowing: .constant(true), score: 100003, gameMode: GameMode.speedMode, restartAction: {}, returnToMenuAction: {})
}
