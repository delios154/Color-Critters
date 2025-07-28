//
//  FeedbackManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit
import AVFoundation

class FeedbackManager {
    static let shared = FeedbackManager()
    
    private var encouragementPhrases = [
        "Great job!",
        "Awesome!",
        "You're amazing!",
        "Keep it up!",
        "Fantastic!",
        "Wonderful!",
        "Excellent!",
        "Super!",
        "Brilliant!",
        "Outstanding!"
    ]
    
    private var nearMissPhrases = [
        "Almost there!",
        "So close!",
        "Try again!",
        "Nearly got it!",
        "Good try!"
    ]
    
    private init() {}
    
    // MARK: - Visual Feedback
    
    func showEncouragementBubble(at position: CGPoint, in scene: SKScene) {
        let phrase = encouragementPhrases.randomElement() ?? "Great!"
        showTextBubble(text: phrase, at: position, in: scene, color: .systemGreen)
    }
    
    func showNearMissFeedback(at position: CGPoint, in scene: SKScene) {
        let phrase = nearMissPhrases.randomElement() ?? "Try again!"
        showTextBubble(text: phrase, at: position, in: scene, color: .systemOrange)
    }
    
    private func showTextBubble(text: String, at position: CGPoint, in scene: SKScene, color: UIColor) {
        // Create bubble background
        let bubble = SKShapeNode()
        let bubblePath = createBubblePath(for: text)
        bubble.path = bubblePath
        bubble.fillColor = color
        bubble.strokeColor = color.darker()
        bubble.lineWidth = 2
        bubble.position = position
        bubble.zPosition = 200
        bubble.alpha = 0
        bubble.setScale(0.8)
        
        // Create text label
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = AccessibilityManager.shared.getAccessibleFontSize(baseSize: 18)
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 5)
        bubble.addChild(label)
        
        scene.addChild(bubble)
        
        // Animate bubble
        let fadeIn = SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        fadeIn.timingMode = .easeOut
        
        let float = SKAction.moveBy(x: 0, y: 30, duration: 1.5)
        float.timingMode = .easeOut
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([fadeIn, float, fadeOut, remove])
        bubble.run(sequence)
    }
    
    private func createBubblePath(for text: String) -> CGPath {
        let width: CGFloat = CGFloat(text.count) * 12 + 40
        let height: CGFloat = 40
        let cornerRadius: CGFloat = 20
        
        let path = UIBezierPath(roundedRect: CGRect(x: -width/2, y: -height/2, width: width, height: height), 
                                cornerRadius: cornerRadius)
        
        // Add speech bubble tail
        path.move(to: CGPoint(x: -10, y: -height/2))
        path.addLine(to: CGPoint(x: 0, y: -height/2 - 10))
        path.addLine(to: CGPoint(x: 10, y: -height/2))
        
        return path.cgPath
    }
    
    // MARK: - Proximity Feedback
    
    func showProximityFeedback(draggedNode: SKNode, targetNode: SKNode, in scene: SKScene) {
        let distance = hypot(draggedNode.position.x - targetNode.position.x,
                           draggedNode.position.y - targetNode.position.y)
        
        let maxDistance: CGFloat = 300
        let normalizedDistance = min(distance / maxDistance, 1.0)
        
        // Create or update proximity indicator
        var proximityIndicator = scene.childNode(withName: "proximityIndicator") as? SKShapeNode
        
        if proximityIndicator == nil {
            proximityIndicator = SKShapeNode()
            proximityIndicator?.name = "proximityIndicator"
            proximityIndicator?.zPosition = 150
            scene.addChild(proximityIndicator!)
        }
        
        // Update indicator based on distance
        if normalizedDistance < 0.5 {
            // Close - show pulsing circle around target
            let radius = 100 * (1 - normalizedDistance * 2)
            proximityIndicator?.path = UIBezierPath(ovalIn: CGRect(x: -radius, y: -radius, 
                                                                  width: radius * 2, height: radius * 2)).cgPath
            proximityIndicator?.strokeColor = .systemGreen
            proximityIndicator?.fillColor = UIColor.systemGreen.withAlphaComponent(0.1)
            proximityIndicator?.lineWidth = 3
            proximityIndicator?.position = targetNode.position
            proximityIndicator?.alpha = 1 - normalizedDistance
            
            // Add pulsing animation
            if proximityIndicator?.action(forKey: "pulse") == nil {
                let pulse = AnimationManager.shared.pulseAnimation(scale: 1.1, duration: 0.5)
                proximityIndicator?.run(SKAction.repeatForever(pulse), withKey: "pulse")
            }
        } else {
            // Far - hide indicator
            proximityIndicator?.alpha = 0
            proximityIndicator?.removeAllActions()
        }
    }
    
    func hideProximityFeedback(in scene: SKScene) {
        scene.childNode(withName: "proximityIndicator")?.removeFromParent()
    }
    
    // MARK: - Streak Feedback
    
    func showStreakMilestone(_ streak: Int, at position: CGPoint, in scene: SKScene) {
        let container = SKNode()
        container.position = position
        container.zPosition = 300
        
        // Create badge background
        let badge = SKShapeNode(circleOfRadius: 50)
        badge.fillColor = .systemYellow
        badge.strokeColor = .systemOrange
        badge.lineWidth = 4
        container.addChild(badge)
        
        // Add streak number
        let streakLabel = SKLabelNode(text: "\(streak)")
        streakLabel.fontName = "AvenirNext-Bold"
        streakLabel.fontSize = 36
        streakLabel.fontColor = .white
        streakLabel.verticalAlignmentMode = .center
        badge.addChild(streakLabel)
        
        // Add "STREAK!" label
        let textLabel = SKLabelNode(text: "STREAK!")
        textLabel.fontName = "AvenirNext-Bold"
        textLabel.fontSize = 24
        textLabel.fontColor = .systemYellow
        textLabel.position = CGPoint(x: 0, y: -70)
        container.addChild(textLabel)
        
        scene.addChild(container)
        
        // Animate
        container.setScale(0)
        container.alpha = 0
        
        let scaleIn = SKAction.scale(to: 1.2, duration: 0.3)
        scaleIn.timingMode = .easeOut
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let appear = SKAction.group([scaleIn, fadeIn])
        
        let bounce = SKAction.scale(to: 1.0, duration: 0.1)
        bounce.timingMode = .easeInEaseOut
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        rotate.timingMode = .easeInEaseOut
        
        let wait = SKAction.wait(forDuration: 1.5)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, bounce, rotate, wait, fadeOut, remove])
        container.run(sequence)
        
        // Add particle burst
        AnimationManager.shared.createStarBurst(at: position, in: scene, color: .systemYellow)
    }
    
    // MARK: - Level Complete Feedback
    
    func showLevelCompleteFeedback(in scene: SKScene, stars: Int, completion: @escaping () -> Void) {
        // Create overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: scene.size)
        overlay.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        overlay.zPosition = 500
        overlay.alpha = 0
        scene.addChild(overlay)
        
        // Fade in overlay
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
        
        // Create celebration container
        let container = SKNode()
        container.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        overlay.addChild(container)
        
        // Add "Level Complete!" text
        let titleLabel = SKLabelNode(text: "Level Complete!")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = AccessibilityManager.shared.getAccessibleFontSize(baseSize: 42)
        titleLabel.fontColor = .systemYellow
        titleLabel.position = CGPoint(x: 0, y: 100)
        container.addChild(titleLabel)
        
        // Add stars
        let starSpacing: CGFloat = 80
        let startX = -CGFloat(stars - 1) * starSpacing / 2
        
        for i in 0..<3 {
            let delay = Double(i) * 0.2
            
            scene.run(SKAction.wait(forDuration: delay)) {
                let star = self.createStar(filled: i < stars)
                star.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: 0)
                star.setScale(0)
                container.addChild(star)
                
                // Animate star appearance
                let scaleIn = AnimationManager.shared.elasticScale(to: 1.0, duration: 0.5)
                star.run(scaleIn)
                
                if i < stars {
                    // Add particle effect for earned stars
                    AnimationManager.shared.createStarBurst(at: star.position, in: scene, color: .systemYellow)
                    HapticManager.shared.playHaptic(.success)
                }
            }
        }
        
        // Add continue button
        scene.run(SKAction.wait(forDuration: 1.5)) {
            let continueButton = self.createContinueButton()
            continueButton.position = CGPoint(x: 0, y: -150)
            continueButton.alpha = 0
            container.addChild(continueButton)
            
            continueButton.run(SKAction.fadeIn(withDuration: 0.3))
            
            // Handle button tap
            continueButton.name = "continueButton"
            continueButton.isUserInteractionEnabled = true
        }
        
        // Store completion handler
        overlay.userData = ["completion": completion]
        overlay.name = "levelCompleteOverlay"
    }
    
    private func createStar(filled: Bool) -> SKShapeNode {
        let star = SKShapeNode()
        let path = createStarPath(size: 60)
        star.path = path
        star.fillColor = filled ? .systemYellow : .systemGray3
        star.strokeColor = filled ? .systemOrange : .systemGray2
        star.lineWidth = 3
        return star
    }
    
    private func createStarPath(size: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let center = CGPoint.zero
        let radius = size / 2
        
        for i in 0..<5 {
            let angle = (CGFloat(i) * 2 * .pi / 5) - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle),
                               y: center.y + radius * sin(angle))
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            
            let innerAngle = angle + .pi / 5
            let innerRadius = radius * 0.5
            let innerPoint = CGPoint(x: center.x + innerRadius * cos(innerAngle),
                                    y: center.y + innerRadius * sin(innerAngle))
            path.addLine(to: innerPoint)
        }
        path.close()
        
        return path.cgPath
    }
    
    private func createContinueButton() -> SKSpriteNode {
        let button = SKSpriteNode(color: .systemGreen, size: CGSize(width: 200, height: 60))
        
        let label = SKLabelNode(text: "Continue")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        // Add rounded corners
        let shape = SKShapeNode(rectOf: button.size, cornerRadius: 30)
        shape.fillColor = .systemGreen
        shape.strokeColor = .clear
        button.texture = nil
        button.color = .clear
        button.addChild(shape)
        shape.zPosition = -1
        
        AccessibilityManager.shared.configureButtonAccessibility(button, label: "Continue", action: "continue to next level")
        
        return button
    }
}

// MARK: - UIColor Extension
extension UIColor {
    func darker() -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: alpha)
    }
}