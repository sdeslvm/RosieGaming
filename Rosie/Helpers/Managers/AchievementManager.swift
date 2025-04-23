//
//  AchievementManager.swift
//  Rosie
//
//  Created by Alex on 31.03.2025.
//

import Foundation
import SwiftUI

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var unlockedAchievements: Set<Achievement> = []
    @Published var showNotification: Bool = false
    @Published var latestAchievement: Achievement?
    
    private let achievementsKey = "unlockedAchievements"
    
    // Tracking variables for achievements
    private(set) var gameStartTime: Date?
    private var successiveCombinations = 0
    private var largeComboCount = 0
    private var level10FlowerCount = 0
    private var consecutiveConnections = 0
    private var recentCombos: [(timestamp: Date, count: Int)] = []
    
    private init() {
        loadAchievements()
    }
    
    // MARK: - Achievement State Management
    
    func unlockAchievement(_ achievement: Achievement) {
        // If already unlocked, do nothing
        guard !unlockedAchievements.contains(achievement) else { return }
        
        // Add to unlocked set
        unlockedAchievements.insert(achievement)
        
        // Save changes
        saveAchievements()
        
        // Broadcast notification - this will be picked up by any observers
        NotificationCenter.default.post(
            name: NSNotification.Name("AchievementUnlocked"),
            object: nil
        )
    }
    
    func hasUnlocked(_ achievement: Achievement) -> Bool {
        return unlockedAchievements.contains(achievement)
    }
    
    private func saveAchievements() {
        let rawValues = unlockedAchievements.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: achievementsKey)
    }
    
    private func loadAchievements() {
        if let rawValues = UserDefaults.standard.array(forKey: achievementsKey) as? [Int] {
            unlockedAchievements = Set(rawValues.compactMap { Achievement(rawValue: $0) })
        }
    }
    
    // MARK: - Game Events
    
    func resetGameSession() {
        successiveCombinations = 0
        consecutiveConnections = 0
        recentCombos = []
        gameStartTime = Date()
        
        // Start tracking game time achievements
        startGameTimeTracking()
    }
    
    private func startGameTimeTracking() {
        // Cancel any existing timers
        NotificationCenter.default.post(name: NSNotification.Name("StopGameTimeTracking"), object: nil)
        
        // Create new timer for tracking game time achievements
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkGameTimeAchievements()
        }
        
        // Add to RunLoop to ensure it continues running
        RunLoop.current.add(timer, forMode: .common)
        
        // Store timer reference for later cancellation
        NotificationCenter.default.post(name: NSNotification.Name("StartGameTimeTracking"), object: timer)
    }
    
    func recordGameStart() {
        gameStartTime = Date()
    }
    
    func recordGameEnd() {
        gameStartTime = nil
        NotificationCenter.default.post(name: NSNotification.Name("StopGameTimeTracking"), object: nil)
    }
    
    func recordSuccessfulCombination() {
        // First combination achievement
        unlockAchievement(.firstbud)
        
        // Count successive combinations
        successiveCombinations += 1
        
        // Check for 10 successful combinations in a row
        if successiveCombinations >= 10 {
            unlockAchievement(.flowermaster)
        }
        
        // Check consecutive connections
        consecutiveConnections += 1
        if consecutiveConnections >= 5 {
            unlockAchievement(.perfectstreak)
        }
        
        // Record timestamp for combo tracking
        let now = Date()
        recentCombos.append((timestamp: now, count: 1))
        
        // Clean up old combos (older than 5 seconds)
        recentCombos = recentCombos.filter { now.timeIntervalSince($0.timestamp) <= 5.0 }
        
        // Check for combo master (3+ combinations in 5 seconds)
        let totalCombosIn5Seconds = recentCombos.reduce(0) { $0 + $1.count }
        if totalCombosIn5Seconds >= 3 {
            unlockAchievement(.combomaster)
        }
    }
    
    func recordFailedCombination() {
        successiveCombinations = 0
    }
    
    func recordPause() {
        consecutiveConnections = 0
    }
    
    func recordLargeCombo() {
        largeComboCount += 1
        
        // Check for expert gardener achievement (50 large combinations)
        if largeComboCount >= 50 {
            unlockAchievement(.gardeningexpert)
        }
    }
    
    func recordQuickCombination(timeInSeconds: Double) {
        if timeInSeconds < 2.0 {
            unlockAchievement(.fastandbeautiful)
        }
    }
    
    func recordMultipleBallsMerge(count: Int) {
        if count >= 3 {
            unlockAchievement(.ohwhatwasbeautiful)
        }
    }
    
    func recordSpecialFlowerFound() {
        // This would be triggered by a special event in the game
        // Currently, there's no concept of "special flowers" in the codebase
        unlockAchievement(.floralfortune)
    }
    
    func recordLevel10FlowerCreated(gameTimeSeconds: TimeInterval) {
        // Creation of the largest (level 10) flower
        unlockAchievement(.explosionofcolors)
        
        // Count for legendary garden achievement
        level10FlowerCount += 1
        if level10FlowerCount >= 5 {
            unlockAchievement(.legendarygarden)
        }
        
        // Check for speedrunner achievement (under 3 minutes)
        if gameTimeSeconds <= 180 {
            unlockAchievement(.floralspeedrunner)
        }
    }
    
    private func checkGameTimeAchievements() {
        guard let startTime = gameStartTime else { return }
        
        let now = Date()
        let gameTimeSeconds = now.timeIntervalSince(startTime)
        
        // Track whether each time-based achievement has been unlocked to avoid checking again
        if !hasUnlocked(.endlessbloom) && gameTimeSeconds >= 300 {
            unlockAchievement(.endlessbloom)
        }
        
        if !hasUnlocked(.masterofthegarden) && gameTimeSeconds >= 600 {
            unlockAchievement(.masterofthegarden)
        }
    }
}
