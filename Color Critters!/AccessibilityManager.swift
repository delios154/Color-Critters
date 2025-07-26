//
//  AccessibilityManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import UIKit
import SpriteKit

class AccessibilityManager {
    static let shared = AccessibilityManager()
    
    private init() {}
    
    // MARK: - VoiceOver Support
    
    func configureAccessibility(for node: SKNode, label: String, hint: String? = nil, traits: UIAccessibilityTraits = .none) {
        node.isAccessibilityElement = true
        node.accessibilityLabel = label
        node.accessibilityHint = hint
        node.accessibilityTraits = traits
    }
    
    func configureCritterAccessibility(_ critter: SKNode, name: String, color: String) {
        let label = "\(name) needs to be colored \(color)"
        let hint = "Drag a \(color) color blob to this \(name)"
        configureAccessibility(for: critter, label: label, hint: hint, traits: .image)
    }
    
    func configureColorBlobAccessibility(_ blob: SKNode, color: String) {
        let label = "\(color) color blob"
        let hint = "Double tap and hold to drag this to a matching critter"
        configureAccessibility(for: blob, label: label, hint: hint, traits: [.button, .allowsDirectInteraction])
    }
    
    func configureButtonAccessibility(_ button: SKNode, label: String, action: String) {
        let hint = "Double tap to \(action)"
        configureAccessibility(for: button, label: label, hint: hint, traits: .button)
    }
    
    // MARK: - Announcements
    
    func announceSuccess(critterName: String, color: String) {
        let announcement = "Great job! You colored the \(critterName) \(color)"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    func announceError() {
        let announcement = "That's not the right color. Try again!"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    func announceNewLevel(_ level: Int, critterName: String, targetColor: String) {
        let announcement = "Level \(level). Help the \(critterName) by coloring it \(targetColor)"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    func announceScore(_ score: Int) {
        let announcement = "Your score is now \(score) points"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    // MARK: - Enhanced Touch Targets
    
    func createAccessibleTouchArea(for node: SKNode, minimumSize: CGSize = CGSize(width: 88, height: 88)) -> SKNode {
        guard let sprite = node as? SKSpriteNode else { return node }
        
        let currentSize = sprite.size
        let touchArea = SKSpriteNode(color: .clear, size: CGSize(
            width: max(currentSize.width, minimumSize.width),
            height: max(currentSize.height, minimumSize.height)
        ))
        
        touchArea.name = "\(sprite.name ?? "node")_touchArea"
        touchArea.position = sprite.position
        touchArea.zPosition = sprite.zPosition + 0.1
        touchArea.isUserInteractionEnabled = false
        
        // Transfer accessibility properties
        touchArea.isAccessibilityElement = sprite.isAccessibilityElement
        touchArea.accessibilityLabel = sprite.accessibilityLabel
        touchArea.accessibilityHint = sprite.accessibilityHint
        touchArea.accessibilityTraits = sprite.accessibilityTraits
        
        return touchArea
    }
    
    // MARK: - High Contrast Support
    
    func getHighContrastColor(for color: UIColor) -> UIColor {
        if UIAccessibility.isDarkerSystemColorsEnabled {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            // Increase saturation and decrease brightness for better contrast
            return UIColor(hue: hue, saturation: min(saturation * 1.3, 1.0), brightness: brightness * 0.8, alpha: alpha)
        }
        return color
    }
    
    func getAccessibleTextColor(for backgroundColor: UIColor) -> UIColor {
        // Calculate contrast ratio and return appropriate text color
        let backgroundLuminance = luminance(of: backgroundColor)
        return backgroundLuminance > 0.5 ? UIColor.black : UIColor.white
    }
    
    private func luminance(of color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance
        let redLinear = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let greenLinear = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let blueLinear = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        
        return 0.2126 * redLinear + 0.7152 * greenLinear + 0.0722 * blueLinear
    }
    
    // MARK: - Reduce Motion Support
    
    func shouldReduceMotion() -> Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    func getAccessibleAnimation(original: SKAction) -> SKAction {
        if shouldReduceMotion() {
            // Return a simplified version of the animation
            if original.duration > 0 {
                return SKAction.wait(forDuration: original.duration * 0.5)
            }
            return SKAction()
        }
        return original
    }
    
    // MARK: - Font Size Support
    
    func getAccessibleFontSize(baseSize: CGFloat) -> CGFloat {
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        
        switch contentSizeCategory {
        case .extraSmall:
            return baseSize * 0.8
        case .small:
            return baseSize * 0.9
        case .medium:
            return baseSize
        case .large:
            return baseSize * 1.1
        case .extraLarge:
            return baseSize * 1.2
        case .extraExtraLarge:
            return baseSize * 1.3
        case .extraExtraExtraLarge:
            return baseSize * 1.4
        case .accessibilityMedium:
            return baseSize * 1.6
        case .accessibilityLarge:
            return baseSize * 1.8
        case .accessibilityExtraLarge:
            return baseSize * 2.0
        case .accessibilityExtraExtraLarge:
            return baseSize * 2.2
        case .accessibilityExtraExtraExtraLarge:
            return baseSize * 2.4
        default:
            return baseSize
        }
    }
    
    // MARK: - Guided Access Support
    
    func configureForGuidedAccess(scene: SKScene) {
        // Disable certain UI elements during guided access
        if UIAccessibility.isGuidedAccessEnabled {
            // Find and disable settings button
            if let settingsButton = scene.childNode(withName: "settingsButton") {
                settingsButton.isUserInteractionEnabled = false
                settingsButton.alpha = 0.5
            }
            
            // Announce guided access mode
            UIAccessibility.post(notification: .announcement, argument: "Guided Access is enabled. Focus on the game!")
        }
    }
}