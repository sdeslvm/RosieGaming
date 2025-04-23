//
//  GameScene.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SpriteKit
import SwiftUI

protocol GameSceneDelegate: AnyObject {
    // Score updates
    func scoreDidUpdate(to score: Int)
    
    // Game state changes
    func gameDidEnd(withScore score: Int)
    func gameDidWin(withScore score: Int)
    
    // Ball spawn notification
    func didSpawnNewBall(ofType type: BallType)
    
    // Combo system
    func comboMultiplierDidChange(to multiplier: Double, timeRemaining: TimeInterval)
    
    // Time reward system (новый метод)
    func timeRewardEarned(seconds: Double, reason: String, at position: CGPoint)
    
    // Achievement notification
    func didUnlockAchievement(_ achievement: Achievement)
}

class GameScene: SKScene {
    // MARK: - Properties
    
    // Constants
    private let containerWidth: CGFloat = 300
    private let containerHeight: CGFloat = 450
    private let wallThickness: CGFloat = 10
    private let boundaryLineHeight: CGFloat = 3
    private let topPadding: CGFloat = 100 // Space above the container for UI
    
    // Game elements
    private var container: SKNode?
    private var boundaryLine: SKNode?
    private var currentBall: Ball?
    private var boundaryNode: SKNode?
    
    // Game state
    private var score: Int = 0
    private var gameActive: Bool = true
    
    // Combo system
    private var comboMultiplier: Double = 1.0
    private var comboTimer: Timer?
    private var comboExpireTime: TimeInterval = 3.0 // 3 seconds to maintain combo
    private var lastMergeTime: Date?
    private var chainReactionCount: Int = 0
    private var isChainReaction: Bool = false
    
    // Delegate to communicate with SwiftUI
    weak var gameDelegate: GameSceneDelegate?
    
    // MARK: - Lifecycle Methods
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupPhysicsWorld()
        setupContainer()
        setupBoundaryLine()
        setupBoundaryNode()
        setupNotificationObservers()
        spawnNewBall()
    }
    
    // MARK: - Setup Methods
    
    private func setupBackground() {
        let effectNode = SKEffectNode()
        effectNode.position = CGPoint(x: frame.midX, y: frame.midY)
        effectNode.zPosition = -100
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(5.0, forKey: "inputRadius")
        effectNode.filter = blurFilter
        
        let backgroundImageName = ShopManager.shared.getEquippedBackground()
        let background = SKSpriteNode(imageNamed: backgroundImageName)
        
        let scaleX = frame.width / background.size.width
        let scaleY = frame.height / background.size.height
        let scale = max(scaleX, scaleY)
        background.setScale(scale)
        background.zPosition = -100
        
        effectNode.addChild(background)
        addChild(effectNode)
    }
    
    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        // Create an edge loop around the entire scene to prevent objects from escaping
        let edgeFrame = CGRect(x: -frame.width/2, y: -frame.height/2, width: frame.width, height: frame.height)
        let edgeBody = SKPhysicsBody(edgeLoopFrom: edgeFrame)
        edgeBody.restitution = 0.2
        edgeBody.friction = 0.2
        edgeBody.categoryBitMask = PhysicsCategory.wall
        edgeBody.collisionBitMask = PhysicsCategory.ball
        edgeBody.contactTestBitMask = PhysicsCategory.none
        
        let edgeNode = SKNode()
        edgeNode.position = CGPoint(x: frame.midX, y: frame.midY)
        edgeNode.physicsBody = edgeBody
        addChild(edgeNode)
    }
    
    private func setupContainer() {
        let container = SKNode()
        container.position = CGPoint(x: frame.midX, y: frame.midY - topPadding/2)
        
        // Left wall
        let leftWall = createWall(
            size: CGSize(width: wallThickness, height: containerHeight),
            position: CGPoint(x: -containerWidth/2 - wallThickness/2, y: 0)
        )
        container.addChild(leftWall)
        
        // Right wall
        let rightWall = createWall(
            size: CGSize(width: wallThickness, height: containerHeight),
            position: CGPoint(x: containerWidth/2 + wallThickness/2, y: 0)
        )
        container.addChild(rightWall)
        
        // Bottom wall
        let bottomWall = createWall(
            size: CGSize(width: containerWidth + wallThickness*2, height: wallThickness),
            position: CGPoint(x: 0, y: -containerHeight/2 - wallThickness/2)
        )
        container.addChild(bottomWall)
        
        self.container = container
        addChild(container)
    }
    
    private func createWall(size: CGSize, position: CGPoint) -> SKShapeNode {
        let wall = SKShapeNode(rectOf: size)
        wall.fillColor = .gray
        wall.strokeColor = .darkGray
        wall.position = position
        wall.lineWidth = 1
        
        // Add physics body
        wall.physicsBody = SKPhysicsBody(rectangleOf: size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.restitution = 0.3
        wall.physicsBody?.friction = 0.2
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.none
        
        return wall
    }
    
    private func setupBoundaryLine() {
        // Since SKShapeNode doesn't support lineDashPattern directly,
        // we'll create a series of small lines to create a dashed effect
        let boundaryNode = SKNode()
        boundaryNode.position = CGPoint(x: container?.position.x ?? frame.midX, y: container?.position.y ?? frame.midY)
        
        let startX = -containerWidth/2 - wallThickness
        let endX = containerWidth/2 + wallThickness
        let segmentLength: CGFloat = 12 // 4 pixels visible, 4 pixels gap
        let y = containerHeight/2
        
        var currentX = startX
        var isDrawn = true // Start with a visible segment
        
        while currentX < endX {
            // Determine segment end position
            let segmentEndX = min(currentX + segmentLength/2, endX)
            
            // Draw segment if it should be visible
            if isDrawn {
                let segment = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: currentX, y: y))
                path.addLine(to: CGPoint(x: segmentEndX, y: y))
                segment.path = path
                segment.strokeColor = .yellow
                segment.lineWidth = boundaryLineHeight
                boundaryNode.addChild(segment)
            }
            
            // Move to next segment
            currentX = segmentEndX
            isDrawn.toggle() // Alternate between drawn and gap
        }
        
        self.boundaryLine = boundaryNode
        addChild(boundaryNode)
    }
    
    private func setupBoundaryNode() {
        // Invisible node at the boundary line to detect crossing
        let node = SKNode()
        let boundaryY = (container?.position.y ?? frame.midY) + containerHeight/2
        node.position = CGPoint(x: frame.midX, y: boundaryY)
        
        let boundarySize = CGSize(width: containerWidth, height: 2)
        node.physicsBody = SKPhysicsBody(rectangleOf: boundarySize, center: .zero)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        
        // Name the node for identification
        node.name = "boundaryTop"
        
        self.boundaryNode = node
        addChild(node)
    }
    
    // MARK: - Game Logic
    
    func spawnNewBall() {
        guard gameActive else { return }
        
        // Create a random ball type, but starting with smaller balls more frequently
        let randomValue = Int.random(in: 0..<100)
        let typeRawValue: Int
        
        if randomValue < 50 {
            typeRawValue = 0  // 50% chance for smallest
        } else if randomValue < 80 {
            typeRawValue = 1  // 30% chance for small
        } else if randomValue < 95 {
            typeRawValue = 2  // 15% chance for medium-small
        } else {
            typeRawValue = 3  // 5% chance for medium
        }
        
        let ballType = BallType(rawValue: typeRawValue) ?? .smallest
        let ball = Ball(type: ballType)
        
        // Position at the top of the container
        if let container = container {
            ball.position = CGPoint(
                x: container.position.x,
                y: container.position.y + containerHeight/2 + 50
            )
        } else {
            ball.position = CGPoint(x: frame.midX, y: frame.midY + containerHeight/2 + 50)
        }
        
        // Initially disable physics until the ball is dropped
        ball.physicsBody?.isDynamic = false
        
        addChild(ball)
        currentBall = ball
        
        // Notify delegate about the new ball
        gameDelegate?.didSpawnNewBall(ofType: ballType)
    }
    
    func gameOver() {
        gameActive = false
        isPaused = true
        SettingsManager.shared.vibrateError()
        gameDelegate?.gameDidEnd(withScore: score)
    }
    
    // MARK: - Ball Merging Logic
    
    func handleBallMerge(ballA: Ball, ballB: Ball) {
        // Only merge balls of the same type
        guard ballA.type == ballB.type, ballA.type != .largest else { return }
        
        // Create a new ball of the next type
        let newType = ballA.type.next()
        let newBall = Ball(type: newType)
        
        // Position at the midpoint between the two balls
        let midPoint = CGPoint(
            x: (ballA.position.x + ballB.position.x) / 2,
            y: (ballA.position.y + ballB.position.y) / 2
        )
        newBall.position = midPoint
        
        // Add slight random velocity to prevent balls from stacking perfectly
        let randomVelocity = CGVector(
            dx: CGFloat.random(in: -20...20),
            dy: CGFloat.random(in: -10...10)
        )
        newBall.physicsBody?.velocity = randomVelocity
        
        // Remove the original balls
        ballA.removeFromParent()
        ballB.removeFromParent()
        
        // Add the new ball
        addChild(newBall)
        
        // Add visual effect (could be improved with textures later)
        let emitter = SKEmitterNode(fileNamed: "MergeParticle")
        emitter?.position = midPoint
        emitter?.zPosition = 1
        if let emitter = emitter {
            addChild(emitter)
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            emitter.run(SKAction.sequence([wait, remove]))
        }
        
        SettingsManager.shared.playSound()
        SettingsManager.shared.vibrateLight()
        
        // Handle combo system
        updateCombo()
        
        // Calculate base points with chain reaction bonus
        var basePoints = newType.points
        
        if isChainReaction {
            // Increase chain reaction count and add bonus
            chainReactionCount += 1
            
            // Chain reaction bonus: 50% more for each step in the chain
            let chainBonus = 1.0 + (Double(chainReactionCount - 1) * 0.5)
            basePoints = Int(Double(basePoints) * chainBonus)
            
            // Display chain reaction text
            showChainText(count: chainReactionCount, at: midPoint)
        } else {
            // Reset chain count
            chainReactionCount = 0
        }
        
        // Apply combo multiplier to total score
        let pointsWithCombo = Int(Double(basePoints) * comboMultiplier)
        score += pointsWithCombo
        
        // Show points text
        showPointsText(points: pointsWithCombo, at: midPoint)
        
        if comboMultiplier > 1.0 || chainReactionCount > 1 {
            let timeReward = calculateTimeReward(forCombo: comboMultiplier, chainReaction: chainReactionCount)
            if timeReward > 0 {
                let reason = comboMultiplier > 1.0 ? "Combo x\(String(format: "%.1f", comboMultiplier))" : "Chain x\(chainReactionCount)"
//                showTimeRewardText(seconds: timeReward, reason: reason, at: midPoint)
                
                gameDelegate?.timeRewardEarned(seconds: timeReward, reason: reason, at: midPoint)
            }
        }
        
        // Check if this merge might cause another merge
        isChainReaction = true
        
        // Schedule a timer to reset chain reaction flag
        let wait = SKAction.wait(forDuration: 0.5)
        let resetChain = SKAction.run { [weak self] in
            self?.isChainReaction = false
        }
        run(SKAction.sequence([wait, resetChain]))
        
        // Notify delegate about score update and combo state
        gameDelegate?.scoreDidUpdate(to: score)
        gameDelegate?.comboMultiplierDidChange(to: comboMultiplier, timeRemaining: comboExpireTime)
        
        // Check for win condition
        if newType == .largest {
            gameWon()
        }
        
        // Track achievements
        let achievementManager = AchievementManager.shared
        achievementManager.recordSuccessfulCombination()

        // If there's a chain reaction with 3+ balls
        if isChainReaction && chainReactionCount >= 3 {
            achievementManager.recordMultipleBallsMerge(count: chainReactionCount)
        }

        // For combo tracking
        if comboMultiplier > 1.0 {
            achievementManager.recordLargeCombo()
        }

        // For quick combinations
        if let lastMergeTime = lastMergeTime {
            let timeSinceLastMerge = Date().timeIntervalSince(lastMergeTime)
            achievementManager.recordQuickCombination(timeInSeconds: timeSinceLastMerge)
        }

        // In the win condition check (if newType == .largest) add:
        if newType == .largest {
            if let startTime = achievementManager.gameStartTime {
                let gameTimeSeconds = Date().timeIntervalSince(startTime)
                achievementManager.recordLevel10FlowerCreated(gameTimeSeconds: gameTimeSeconds)
            }
            gameWon()
        }
    }
    
    private func updateCombo() {
        // Cancel existing timer
        comboTimer?.invalidate()
        
        let now = Date()
        
        // If we had a recent merge, increase the combo
        if let lastTime = lastMergeTime, now.timeIntervalSince(lastTime) < comboExpireTime {
            // Increase multiplier, cap at 3.0
            comboMultiplier = min(comboMultiplier + 0.5, 3.0)
        } else {
            // Reset multiplier if too much time has passed
            comboMultiplier = 1.0
        }
        
        // Update last merge time
        lastMergeTime = now
        
        // Start new timer to reset combo
        comboTimer = Timer.scheduledTimer(withTimeInterval: comboExpireTime, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Reset combo on main thread
            DispatchQueue.main.async {
                self.comboMultiplier = 1.0
                self.gameDelegate?.comboMultiplierDidChange(to: self.comboMultiplier, timeRemaining: 0)
            }
        }
    }
    
    private func checkAchievements() {
        // Only check if game is active
        guard gameActive else { return }
        
        let achievementManager = AchievementManager.shared
        
        // Check continuous play achievements
        if let startTime = achievementManager.gameStartTime {
            let gameTimeSeconds = Date().timeIntervalSince(startTime)
            
            // 5 minutes of play achievement
            if gameTimeSeconds >= 300 {
                achievementManager.unlockAchievement(.endlessbloom)
            }
            
            // 10 minutes of play achievement
            if gameTimeSeconds >= 600 {
                achievementManager.unlockAchievement(.masterofthegarden)
            }
        }
    }
    
    private func showPointsText(points: Int, at position: CGPoint) {
        let pointsText = SKLabelNode(fontNamed: "Arial-Bold")
        pointsText.text = "+\(points)"
        pointsText.fontSize = 20
        pointsText.fontColor = (comboMultiplier > 1.0) ? .yellow : .white
        pointsText.position = CGPoint(x: position.x, y: position.y + 20)
        pointsText.zPosition = 10
        addChild(pointsText)
        
        // Animate and remove
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        pointsText.run(SKAction.sequence([group, remove]))
    }
    
    private func showChainText(count: Int, at position: CGPoint) {
        let chainText = SKLabelNode(fontNamed: "Arial-Bold")
        chainText.text = "Chain x\(count)!"
        chainText.fontSize = 22
        chainText.fontColor = .orange
        chainText.position = CGPoint(x: position.x, y: position.y - 20)
        chainText.zPosition = 10
        addChild(chainText)
        
        // Animate and remove
        let scale = SKAction.scale(by: 1.5, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 0.3)
        let remove = SKAction.removeFromParent()
        chainText.run(SKAction.sequence([scale, wait, fadeOut, remove]))
    }
    
    private func calculateTimeReward(forCombo combo: Double, chainReaction: Int) -> Double {

        var reward = 0.0
        
        if combo >= 2.5 {
            reward = 3.0
        } else if combo >= 2.0 {
            reward = 2.0
        } else if combo >= 1.5 {
            reward = 1.0
        }
        
        if chainReaction > 1 {
            reward += min(Double(chainReaction), 2.0)
        }
        
        return reward
    }
    
//    private func showTimeRewardText(seconds: Double, reason: String, at position: CGPoint) {
//        let timeText = SKLabelNode(fontNamed: "Arial-Bold")
//        timeText.text = "+\(String(format: "%.1f", seconds))s"
//        timeText.fontSize = 22
//        timeText.fontColor = .green
//        timeText.position = CGPoint(x: position.x, y: position.y + 30)
//        timeText.zPosition = 10
//        addChild(timeText)
//        
//        let reasonText = SKLabelNode(fontNamed: "Arial")
//        reasonText.text = reason
//        reasonText.fontSize = 16
//        reasonText.fontColor = .white
//        reasonText.position = CGPoint(x: position.x, y: position.y + 10)
//        reasonText.zPosition = 10
//        addChild(reasonText)
//        
//        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
//        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
//        let group = SKAction.group([moveUp, fadeOut])
//        let remove = SKAction.removeFromParent()
//        
//        timeText.run(SKAction.sequence([group, remove]))
//        reasonText.run(SKAction.sequence([group, remove]))
//    }
    
    private func gameWon() {
        gameActive = false
        isPaused = true
        SettingsManager.shared.vibrateSuccess()
        gameDelegate?.gameDidWin(withScore: score)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, gameActive else { return }
        let location = touch.location(in: self)
        
        if let currentBall = currentBall {
            currentBall.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, gameActive else { return }
        let location = touch.location(in: self)
        
        if let currentBall = currentBall, let container = container {
            // Convert container bounds to scene coordinates
            let minX = container.position.x - containerWidth/2 + currentBall.frame.width/2
            let maxX = container.position.x + containerWidth/2 - currentBall.frame.width/2
            
            // Constrain horizontal movement within container bounds
            currentBall.position.x = min(maxX, max(minX, location.x))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameActive else { return }
        
        if let currentBall = currentBall {
            // Enable physics to make the ball fall
            currentBall.physicsBody?.isDynamic = true
            
            // Mark the ball as dropping
            currentBall.isDropping = true
            
            // Start a timer to mark the ball as "settled" after a delay
            // This prevents immediate game over when the ball crosses the boundary
            let settleDelay = 1.5 // seconds
            let waitAction = SKAction.wait(forDuration: settleDelay)
            let settleAction = SKAction.run { [weak currentBall] in
                currentBall?.isDropping = false
            }
            currentBall.run(SKAction.sequence([waitAction, settleAction]))
            
            // Clear the current ball reference
            self.currentBall = nil
            
            // Wait a bit before spawning a new ball
            let wait = SKAction.wait(forDuration: 1.0)
            let spawn = SKAction.run { [weak self] in
                self?.spawnNewBall()
            }
            run(SKAction.sequence([wait, spawn]))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Check for time-based achievements periodically
        if Int(currentTime) % 10 == 0 { // Check every ~10 seconds
            checkAchievements()
        }
    }
    
    deinit {
        removeNotificationObservers()
    }
}

// MARK: - Physics Contact Delegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Get the two bodies involved in the contact
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Check for ball-to-ball collision
        if let ballA = bodyA.node as? Ball, let ballB = bodyB.node as? Ball {
            // Воспроизводим звук и вибрацию при коллизии шаров
            SettingsManager.shared.playSound()
            SettingsManager.shared.vibrateLight()
            
            // Handle ball collision
            if ballA.type == ballB.type {
                // Using DispatchQueue to avoid physics simulation interruption
                DispatchQueue.main.async { [weak self] in
                    self?.handleBallMerge(ballA: ballA, ballB: ballB)
                }
            }
            return
        }
        
        // Check for ball crossing the boundary (game over condition)
        if let boundaryBody = (bodyA.categoryBitMask == PhysicsCategory.boundary) ? bodyA :
            ((bodyB.categoryBitMask == PhysicsCategory.boundary) ? bodyB : nil),
           let ballBody = (bodyA.categoryBitMask == PhysicsCategory.ball) ? bodyA :
            ((bodyB.categoryBitMask == PhysicsCategory.ball) ? bodyB : nil),
           let ball = ballBody.node as? Ball,
           let boundary = boundaryBody.node,
           boundary.name == "boundaryTop" {
            
            // Check if ball is moving upward (essential check!)
            // Only trigger game over if the ball is moving upward AND is not in dropping state
            let ballVelocity = ballBody.velocity
            let isMovingUpward = ballVelocity.dy > 0
            
            if isMovingUpward && !ball.isDropping {
                // Game over - a ball has crossed the boundary line from below
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Вибрация при проигрыше
                    SettingsManager.shared.vibrateError()
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.gameOver()
                }
            }
            return
        }
    }
}

extension GameScene {
    func updateBackground() {
        self.children.filter { $0 is SKEffectNode }.forEach { $0.removeFromParent() }
        
        let effectNode = SKEffectNode()
        effectNode.position = CGPoint(x: frame.midX, y: frame.midY)
        effectNode.zPosition = -100
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(5.0, forKey: "inputRadius")
        effectNode.filter = blurFilter
        
        let backgroundImageName = ShopManager.shared.getEquippedBackground()
        
        let background = SKSpriteNode(imageNamed: backgroundImageName)
        
        let scaleX = frame.width / background.size.width
        let scaleY = frame.height / background.size.height
        let scale = max(scaleX, scaleY)
        background.setScale(scale)
        background.zPosition = -100
        
        effectNode.addChild(background)
        addChild(effectNode)
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBackgroundRefresh),
            name: Notification.Name("RefreshBackground"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBallTexturesRefresh),
            name: Notification.Name("RefreshBallTextures"),
            object: nil
        )
    }
    
    @objc private func handleBackgroundRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.updateBackground()
        }
    }
    
    @objc private func handleBallTexturesRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.updateBallTextures()
        }
    }
    
    func updateBallTextures() {
        self.enumerateChildNodes(withName: "ball-*") { node, _ in
            if let ball = node as? Ball {
                ball.updateAppearance()
            }
        }
    }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
