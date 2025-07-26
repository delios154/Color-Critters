//
//  AnimationManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit
import GameplayKit

class AnimationManager {
    static let shared = AnimationManager()
    
    private init() {}
    
    // MARK: - Particle Effects
    
    func createStarBurst(at position: CGPoint, in scene: SKScene, color: UIColor = .yellow) {
        let particleEmitter = SKEmitterNode()
        particleEmitter.position = position
        particleEmitter.particleTexture = createStarTexture()
        particleEmitter.particleBirthRate = 150
        particleEmitter.numParticlesToEmit = 20
        particleEmitter.particleLifetime = 1.0
        particleEmitter.particleSpeed = 200
        particleEmitter.particleSpeedRange = 50
        particleEmitter.emissionAngleRange = .pi * 2
        particleEmitter.particleScale = 0.3
        particleEmitter.particleScaleRange = 0.2
        particleEmitter.particleScaleSpeed = -0.5
        particleEmitter.particleAlpha = 1.0
        particleEmitter.particleAlphaSpeed = -1.0
        particleEmitter.particleColor = color
        particleEmitter.particleColorBlendFactor = 1.0
        particleEmitter.zPosition = 100
        
        scene.addChild(particleEmitter)
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])
        particleEmitter.run(removeAction)
    }
    
    func createColorSplash(at position: CGPoint, in scene: SKScene, color: UIColor) {
        let particleEmitter = SKEmitterNode()
        particleEmitter.position = position
        particleEmitter.particleTexture = createCircleTexture()
        particleEmitter.particleBirthRate = 100
        particleEmitter.numParticlesToEmit = 30
        particleEmitter.particleLifetime = 1.5
        particleEmitter.particleSpeed = 150
        particleEmitter.particleSpeedRange = 50
        particleEmitter.emissionAngle = .pi / 2
        particleEmitter.emissionAngleRange = .pi / 4
        particleEmitter.particleScale = 0.5
        particleEmitter.particleScaleRange = 0.3
        particleEmitter.particleScaleSpeed = -0.3
        particleEmitter.particleAlpha = 0.8
        particleEmitter.particleAlphaSpeed = -0.5
        particleEmitter.particleColor = color
        particleEmitter.particleColorBlendFactor = 1.0
        particleEmitter.yAcceleration = -100
        particleEmitter.zPosition = 100
        
        scene.addChild(particleEmitter)
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ])
        particleEmitter.run(removeAction)
    }
    
    func createTrailEffect(for node: SKNode, color: UIColor) -> SKEmitterNode {
        let particleEmitter = SKEmitterNode()
        particleEmitter.particleTexture = createCircleTexture()
        particleEmitter.particleBirthRate = 50
        particleEmitter.particleLifetime = 0.5
        particleEmitter.particleSpeed = 0
        particleEmitter.particleScale = 0.3
        particleEmitter.particleScaleSpeed = -0.6
        particleEmitter.particleAlpha = 0.6
        particleEmitter.particleAlphaSpeed = -1.2
        particleEmitter.particleColor = color
        particleEmitter.particleColorBlendFactor = 1.0
        particleEmitter.targetNode = node.parent
        particleEmitter.zPosition = node.zPosition - 1
        
        return particleEmitter
    }
    
    // MARK: - Advanced Animations
    
    func pulseAnimation(scale: CGFloat = 1.2, duration: TimeInterval = 0.3) -> SKAction {
        let scaleUp = SKAction.scale(to: scale, duration: duration/2)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(to: 1.0, duration: duration/2)
        scaleDown.timingMode = .easeInEaseOut
        return SKAction.sequence([scaleUp, scaleDown])
    }
    
    func bounceAnimation(height: CGFloat = 20, duration: TimeInterval = 0.5) -> SKAction {
        let moveUp = SKAction.moveBy(x: 0, y: height, duration: duration/2)
        moveUp.timingMode = .easeOut
        let moveDown = SKAction.moveBy(x: 0, y: -height, duration: duration/2)
        moveDown.timingMode = .easeIn
        return SKAction.sequence([moveUp, moveDown])
    }
    
    func wobbleAnimation(angle: CGFloat = 0.15, duration: TimeInterval = 0.1) -> SKAction {
        let rotateLeft = SKAction.rotate(toAngle: -angle, duration: duration)
        let rotateRight = SKAction.rotate(toAngle: angle, duration: duration)
        let rotateCenter = SKAction.rotate(toAngle: 0, duration: duration)
        return SKAction.sequence([rotateLeft, rotateRight, rotateLeft, rotateRight, rotateCenter])
    }
    
    func elasticScale(to scale: CGFloat, duration: TimeInterval = 0.4) -> SKAction {
        let overshoot = scale * 1.1
        let scaleUp = SKAction.scale(to: overshoot, duration: duration * 0.6)
        scaleUp.timingMode = .easeOut
        let scaleBack = SKAction.scale(to: scale, duration: duration * 0.4)
        scaleBack.timingMode = .easeInEaseOut
        return SKAction.sequence([scaleUp, scaleBack])
    }
    
    func floatingAnimation(amplitude: CGFloat = 10, duration: TimeInterval = 2.0) -> SKAction {
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addCurve(to: CGPoint(x: 0, y: amplitude),
                      control1: CGPoint(x: amplitude/2, y: amplitude/2),
                      control2: CGPoint(x: -amplitude/2, y: amplitude/2))
        path.addCurve(to: CGPoint.zero,
                      control1: CGPoint(x: -amplitude/2, y: amplitude/2),
                      control2: CGPoint(x: amplitude/2, y: amplitude/2))
        
        let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: duration)
        followPath.timingMode = .easeInEaseOut
        return SKAction.repeatForever(followPath)
    }
    
    func popInAnimation(from scale: CGFloat = 0.0, duration: TimeInterval = 0.5) -> SKAction {
        let scaleAction = SKAction.scale(to: 1.0, duration: duration)
        scaleAction.timingMode = .easeOut
        let fadeIn = SKAction.fadeIn(withDuration: duration * 0.3)
        return SKAction.group([scaleAction, fadeIn])
    }
    
    func popOutAnimation(to scale: CGFloat = 0.0, duration: TimeInterval = 0.3) -> SKAction {
        let scaleAction = SKAction.scale(to: scale, duration: duration)
        scaleAction.timingMode = .easeIn
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        return SKAction.group([scaleAction, fadeOut])
    }
    
    // MARK: - Success Animations
    
    func celebrateSuccess(at position: CGPoint, in scene: SKScene) {
        // Create multiple star bursts with different colors
        let colors: [UIColor] = [.systemYellow, .systemOrange, .systemPink, .systemPurple]
        for (index, color) in colors.enumerated() {
            let delay = SKAction.wait(forDuration: Double(index) * 0.1)
            let createBurst = SKAction.run { [weak self] in
                self?.createStarBurst(at: position, in: scene, color: color)
            }
            scene.run(SKAction.sequence([delay, createBurst]))
        }
        
        // Add success label animation
        let successLabel = SKLabelNode(text: "Amazing!")
        successLabel.fontName = "AvenirNext-Bold"
        successLabel.fontSize = 36
        successLabel.fontColor = .systemYellow
        successLabel.position = position
        successLabel.zPosition = 101
        successLabel.setScale(0)
        scene.addChild(successLabel)
        
        let popIn = popInAnimation(duration: 0.3)
        let wait = SKAction.wait(forDuration: 1.0)
        let popOut = popOutAnimation(duration: 0.3)
        let remove = SKAction.removeFromParent()
        
        successLabel.run(SKAction.sequence([popIn, wait, popOut, remove]))
    }
    
    // MARK: - Helper Methods
    
    private func createStarTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.white.cgColor)
        
        let starPath = UIBezierPath()
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let radius: CGFloat = 12
        
        for i in 0..<5 {
            let angle = (CGFloat(i) * 2 * .pi / 5) - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle),
                               y: center.y + radius * sin(angle))
            if i == 0 {
                starPath.move(to: point)
            } else {
                starPath.addLine(to: point)
            }
            
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: center.x + radius * 0.5 * cos(innerAngle),
                                    y: center.y + radius * 0.5 * sin(innerAngle))
            starPath.addLine(to: innerPoint)
        }
        starPath.close()
        starPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    private func createCircleTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 4, y: 4, width: 24, height: 24))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
}