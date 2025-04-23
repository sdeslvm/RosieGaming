//
//  GameView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel: GameViewModel
    @State private var showLeaderboard = false
    @State private var showPauseMenu = false
    @State private var showGameOver = false
    @State private var showWin = false
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Initialization
    
    init(gameMode: GameMode = .classic) {
        // Init viewModel with the selected game mode
        _viewModel = StateObject(wrappedValue: GameViewModel(gameMode: gameMode))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // SpriteKit scene
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear {
                    setupGameHandlers()
                    viewModel.startGame()
                }
            
            // UI Overlay
            gameOverlay
            
            // Modal overlays
            if showLeaderboard {
                LeaderboardView(
                    isShowing: $showLeaderboard,
                    playerScore: viewModel.score,
                    gameMode: viewModel.gameMode
                )
                .transition(.opacity)
                .zIndex(10)
            }
            
            if showPauseMenu {
                PauseMenuView(
                    isShowing: $showPauseMenu,
                    resumeAction: resumeGame,
                    restartAction: restartGame,
                    returnToMenuAction: returnToMenu
                )
                .transition(.opacity)
                .zIndex(10)
            }
            
            if showGameOver {
                GameOverView(
                    isShowing: $showGameOver,
                    score: viewModel.score,
                    gameMode: viewModel.gameMode,
                    restartAction: restartGame,
                    returnToMenuAction: returnToMenu
                )
                .transition(.scale)
                .zIndex(10)
            }
            
            if showWin {
                WinView(
                    isShowing: $showWin,
                    score: viewModel.score,
                    gameMode: viewModel.gameMode,
                    nextLevelAction: nextLevel,
                    returnToMenuAction: returnToMenu
                )
                .transition(.scale)
                .zIndex(10)
            }
            
            // Achievement notification
            if viewModel.showAchievementNotification {
                VStack {
                    AchievementNotificationView()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showAchievementNotification)
                    
                    Spacer()
                }
                .zIndex(30)
                .padding(.top, 40)
                .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - UI Components

    private var gameOverlay: some View {
        VStack {
            // Top toolbar
            HStack(alignment: .top) {
                // Leaderboard button
                Button {
                    withAnimation { showLeaderboard = true }
                } label: {
                    Image(.leadboard)
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Spacer()
                
                // Score and mode display
                VStack(spacing: 2) {
                    VStack {
                        Text("SCORE")
                            .myfont(38)
                        
                        Text("\(viewModel.score)")
                            .myfontNumbers(24)
                    }
                }
                
                Spacer()
                
                // Pause button
                Button {
                    viewModel.pauseGame()
                    withAnimation { showPauseMenu = true }
                } label: {
                    Image(.settings)
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
             
            Spacer()
            
            HStack {
                // Timer for Speed Mode
                if viewModel.gameMode == .speedMode {
                    TimerView(
                        timeRemaining: $viewModel.timeRemaining,
                        totalTime: viewModel.gameMode.timerDuration ?? 30,
                        recentTimeReward: $viewModel.recentTimeReward,
                        showTimeRewardAnimation: $viewModel.showTimeRewardAnimation
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Combo indicator
                ComboIndicatorView(
                    multiplier: $viewModel.comboMultiplier,
                    timeRemaining: $viewModel.comboTimeRemaining,
                    isActive: $viewModel.isComboActive
                )
                .frame(width: 150)
                .opacity(viewModel.isComboActive ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isComboActive)
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupGameHandlers() {
        viewModel.gameOverHandler = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showGameOver = true }
            }
        }
        
        viewModel.gameWinHandler = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showWin = true }
            }
        }
    }
    
    private func resumeGame() {
        viewModel.resumeGame()
        withAnimation { showPauseMenu = false }
    }
    
    private func restartGame() {
        withAnimation {
            showPauseMenu = false
            showGameOver = false
            showWin = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.restartGame()
        }
    }
    
    private func nextLevel() {
        withAnimation { showWin = false }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.nextLevel()
        }
    }
    
    private func returnToMenu() {
        dismiss()
    }
}

#Preview {
    GameView()
}
