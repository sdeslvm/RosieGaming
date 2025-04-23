//
//  GameViewModel.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI
import SpriteKit
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var score: Int = 0
    @Published var gameState: GameState = .ready
    @Published var nextBallType: BallType = .smallest
    
    // Combo system
    @Published var comboMultiplier: Double = 1.0
    @Published var comboTimeRemaining: Double = 0
    @Published var isComboActive: Bool = false
    
    @Published var recentTimeReward: (seconds: Double, reason: String)? = nil
    @Published var showTimeRewardAnimation: Bool = false
    
    // Game mode and timer
    @Published var gameMode: GameMode
    @Published var timeRemaining: TimeInterval = 0
    @Published var isTimerActive: Bool = false
    
    // Achievement system
    @Published var showAchievementNotification: Bool = false
    private var achievementNotificationTimer: Timer?
    private var achievementManager = AchievementManager.shared
    
    // MARK: - Properties
    
    // SpriteKit scene
    let scene: GameScene
    
    // Handlers for game events
    var gameOverHandler: (() -> Void)?
    var gameWinHandler: (() -> Void)?
    
    // Timer for Speed Mode
    private var gameTimer: Timer?
    
    // MARK: - Initialization
    
    init(gameMode: GameMode = .classic) {
        // Set the game mode
        self.gameMode = gameMode
        
        // Create scene with size that fits the device screen
        let screenSize = UIScreen.main.bounds.size
        scene = GameScene(size: screenSize)
        scene.scaleMode = .aspectFill
        
        // Set up delegate
        scene.gameDelegate = self
        
        // Initialize timer if needed
        if let duration = gameMode.timerDuration {
            self.timeRemaining = duration
        }
        
        // Reset achievement tracking for new game session
        achievementManager.resetGameSession()
        
        // Set up notification observer for achievement unlocks
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAchievementUnlocked),
            name: NSNotification.Name("AchievementUnlocked"),
            object: nil
        )
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Achievement Handling
    
    @objc private func handleAchievementUnlocked() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Show notification
            withAnimation {
                self.showAchievementNotification = true
            }
            
            // Cancel any existing timer
            self.achievementNotificationTimer?.invalidate()
            
            // Auto-hide notification after 1 second
            self.achievementNotificationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                withAnimation {
                    self?.showAchievementNotification = false
                }
            }
        }
    }
    
    // MARK: - Game Control Methods
    
    func startGame() {
        gameState = .playing
        scene.isPaused = false
        
        // Start achievement tracking
        achievementManager.recordGameStart()
        
        // Start timer if we're in speed mode
        if gameMode == .speedMode {
            startGameTimer()
        }
    }
    
    func pauseGame() {
        scene.isPaused = true
        gameState = .paused
        
        // Notify achievement manager about pause
        achievementManager.recordPause()
        
        // Pause timer if active
        if isTimerActive {
            gameTimer?.invalidate()
        }
    }
    
    func resumeGame() {
        scene.isPaused = false
        gameState = .playing
        
        // Resume timer if in speed mode
        if gameMode == .speedMode && gameState == .playing {
            startGameTimer()
        }
    }
    
    func restartGame() {
        let newScene = GameScene(size: scene.size)
        newScene.scaleMode = scene.scaleMode
        newScene.gameDelegate = self
        
        if let view = scene.view {
            view.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        score = 0
        gameState = .playing
        
        // Reset achievement tracking for new game
        achievementManager.resetGameSession()
        
        if gameMode == .speedMode {
            timeRemaining = gameMode.timerDuration ?? 30
            startGameTimer()
        }
    }
    
    func nextLevel() {
        let newScene = GameScene(size: scene.size)
        newScene.scaleMode = scene.scaleMode
        newScene.gameDelegate = self
        
        if let view = scene.view {
            view.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        gameState = .playing
        
        // Reset achievement tracking for new level
        achievementManager.resetGameSession()
        
        if gameMode == .speedMode {
            timeRemaining = gameMode.timerDuration ?? 30
            startGameTimer()
        }
    }
    
    func cleanup() {
        // End game session tracking for achievements
        achievementManager.recordGameEnd()
        
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AchievementUnlocked"), object: nil)
        
        // Cancel any pending timers
        gameTimer?.invalidate()
        achievementNotificationTimer?.invalidate()
    }
    
    // MARK: - Timer Management
    
    private func startGameTimer() {
        // Cancel any existing timer
        gameTimer?.invalidate()
        
        // Only start timer if we have a duration
        guard let duration = gameMode.timerDuration, duration > 0 else { return }
        
        isTimerActive = true
        
        // Start a timer that updates every 0.1 seconds
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Decrease timer
            self.timeRemaining -= 0.1
            
            // Check if timer expired
            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                self.isTimerActive = false
                self.gameTimer?.invalidate()
                
                // End game when timer expires
                self.handleSpeedModeEnd()
            }
        }
    }
    
    private func handleSpeedModeEnd() {
        // Game over with current score
        gameState = .gameOver
        scene.isPaused = true
        
        // Save high score for this mode
        saveHighScore(score)
        
        // End achievement tracking
        achievementManager.recordGameEnd()
        
        // Trigger game over handler
        gameOverHandler?()
    }
    
    // MARK: - Persistence Methods
    
    private func saveHighScore(_ score: Int) {
        // Get the appropriate key for the current game mode
        let highScoreKey = gameMode.leadersKey
        
        let currentHighScore = UserDefaults.standard.integer(forKey: highScoreKey)
        if score > currentHighScore {
            UserDefaults.standard.set(score, forKey: highScoreKey)
        }
    }
}

// MARK: - GameSceneDelegate Implementation

extension GameViewModel: GameSceneDelegate {
    func scoreDidUpdate(to score: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.score = score
        }
    }
    
    func gameDidEnd(withScore score: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.gameState = .gameOver
            self.gameOverHandler?()
            
            // End achievement tracking
            self.achievementManager.recordGameEnd()
            
            // Save high score
            self.saveHighScore(score)
        }
    }
    
    func gameDidWin(withScore score: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.gameState = .win
            self.gameWinHandler?()
            
            // End achievement tracking
            self.achievementManager.recordGameEnd()
            
            // Save high score
            self.saveHighScore(score)
            
            // Handle in-game currency reward here
        }
    }
    
    func didSpawnNewBall(ofType type: BallType) {
        DispatchQueue.main.async { [weak self] in
            self?.nextBallType = type
        }
    }
    
    func comboMultiplierDidChange(to multiplier: Double, timeRemaining: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.comboMultiplier = multiplier
            self?.comboTimeRemaining = timeRemaining
            self?.isComboActive = multiplier > 1.0
            
            // If combo is active, start countdown timer to update UI
            if multiplier > 1.0 && timeRemaining > 0 {
                self?.startComboCountdown(from: timeRemaining)
            }
        }
    }
    
    func didUnlockAchievement(_ achievement: Achievement) {
        // This is now handled via NotificationCenter
    }
    
    private func startComboCountdown(from seconds: TimeInterval) {
        // Cancel any existing timers
        Timer.cancelPreviousPerformRequests(withTarget: self)
        
        comboTimeRemaining = seconds
        
        // Schedule countdown updates (10 updates per second)
        let updateInterval = 0.1
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.comboTimeRemaining -= updateInterval
            
            // Stop when timer reaches zero or combo is no longer active
            if self.comboTimeRemaining <= 0 || !self.isComboActive {
                self.comboTimeRemaining = 0
                timer.invalidate()
            }
        }
    }
    
    func timeRewardEarned(seconds: Double, reason: String, at position: CGPoint) {
        // only Speed Mode
        guard gameMode == .speedMode, gameState == .playing else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.timeRemaining += seconds
            
            self.recentTimeReward = (seconds, reason)
            self.showTimeRewardAnimation = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showTimeRewardAnimation = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.recentTimeReward = nil
                }
            }
        }
    }
}
