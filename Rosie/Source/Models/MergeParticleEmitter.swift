//
//  MergeParticleEmitter.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SpriteKit

// This file provides an alternative to using the .sks file
// The actual particle system would normally be created in SpriteKit's particle editor
class MergeParticleEmitter {
    static func createMergeEmitter(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Basic properties
        emitter.particleLifetime = 0.7
        emitter.particleLifetimeRange = 0.2
        emitter.numParticlesToEmit = 30
        emitter.particleBirthRate = 200
        
        // Appearance
        emitter.particleSize = CGSize(width: 10, height: 10)
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor.yellow,
            UIColor.orange,
            UIColor.clear
        ], times: [0, 0.2, 0.4, 1.0])
        
        // Motion
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2.0
        emitter.xAcceleration = 0
        emitter.yAcceleration = -20
        
        // Alpha and scale
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0.0, 1.0, 0.0], times: [0.0, 0.1, 1.0])
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [0.0, 1.5, 0.0], times: [0.0, 0.1, 1.0])
        
        // Blend mode
        emitter.particleBlendMode = .add
        
        // Position
        emitter.position = position
        emitter.targetNode = emitter.scene
        
        return emitter
    }
    
    // Convenience method to add a merge effect to a scene
    static func addMergeEffect(to scene: SKScene, at position: CGPoint) {
        let emitter = createMergeEmitter(at: position)
        scene.addChild(emitter)
        
        // Auto-removal
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
}
