//
//  Ball.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SpriteKit

class Ball: SKShapeNode {

    private enum PhysicsCategory {
        static let none: UInt32 = 0
        static let ball: UInt32 = 0x1
        static let wall: UInt32 = 0x1 << 1
    }
    
    let type: BallType
    var isDropping: Bool = true
    
    init(type: BallType) {
        self.type = type
        super.init()
        
        setupAppearance()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupAppearance() {
        let radius = type.size / 2
        let path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: type.size, height: type.size), transform: nil)
        self.path = path
        
        let imageName = ShopManager.shared.getEquippedBall(for: type)
        let texture = SKTexture(imageNamed: imageName)
        self.fillTexture = texture
        self.fillColor = .white
        
        self.strokeColor = .clear
        self.lineWidth = 0
        self.name = "ball-\(type.rawValue)"
    }
    
    private func setupPhysics() {
        let radius = type.size / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.restitution = 0.5 
        self.physicsBody?.friction = 0.2
        self.physicsBody?.linearDamping = 0.5
        
        self.physicsBody?.mass = CGFloat(type.rawValue + 1) * 0.3
        
        self.physicsBody?.categoryBitMask = PhysicsCategory.ball
        self.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.wall
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
    
    func updateAppearance() {
        let imageName = ShopManager.shared.getEquippedBall(for: type)
        let texture = SKTexture(imageNamed: imageName)
        self.fillTexture = texture
    }
}
