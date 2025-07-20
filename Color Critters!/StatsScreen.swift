//
//  StatsScreen.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

protocol StatsScreenDelegate: AnyObject {
    func statsScreenDidClose()
}

class StatsScreen: SKNode {
    
    weak var delegate: StatsScreenDelegate?
    var isActive = false
    
    override init() {
        super.init()
        setupStatsScreen()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStatsScreen()
    }
    
    private func setupStatsScreen() {
        zPosition = 150
        isHidden = true
    }
    
    func showStats() {
        guard !isActive else { return }
        
        isActive = true
        isHidden = false
        
        // Create background overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.scene?.size ?? CGSize.zero)
        overlay.position = CGPoint(x: (self.scene?.size.width ?? 0) / 2, y: (self.scene?.size.height ?? 0) / 2)
        addChild(overlay)
        
        // Create stats container
        let statsContainer = SKSpriteNode.roundedRect(color: .white, size: CGSize(width: 350, height: 520), cornerRadius: 25)
        statsContainer.position = CGPoint(x: (self.scene?.size.width ?? 0) / 2, y: (self.scene?.size.height ?? 0) / 2)
        addChild(statsContainer)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Your Progress 📊"
        titleLabel.fontSize = 30
        titleLabel.fontColor = .darkGray
        titleLabel.position = CGPoint(x: 0, y: 210)
        statsContainer.addChild(titleLabel)
        
        // Stats
        let settings = GameSettings.shared
        let stats = [
            ("Current Level", "\(settings.currentLevel)"),
            ("Total Score", "\(settings.totalScore)"),
            ("High Score", "\(settings.highScore)"),
            ("Correct Matches", "\(settings.correctMatches)"),
            ("Total Matches", "\(settings.totalMatches)"),
            ("Accuracy", String(format: "%.1f%%", settings.getAccuracy()))
        ]
        
        for (index, (label, value)) in stats.enumerated() {
            let yPosition = 130 - (index * 45)
            
            // Label
            let labelNode = SKLabelNode(fontNamed: "AvenirNext-Regular")
            labelNode.text = label
            labelNode.fontSize = 18
            labelNode.fontColor = .darkGray
            labelNode.horizontalAlignmentMode = .left
            labelNode.position = CGPoint(x: -130, y: yPosition)
            statsContainer.addChild(labelNode)
            
            // Value
            let valueNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
            valueNode.text = value
            valueNode.fontSize = 20
            valueNode.fontColor = .black
            valueNode.horizontalAlignmentMode = .right
            valueNode.position = CGPoint(x: 130, y: yPosition)
            statsContainer.addChild(valueNode)
        }
        
        // Achievements section
        let achievementsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        achievementsLabel.text = "Achievements 🏆"
        achievementsLabel.fontSize = 22
        achievementsLabel.fontColor = .darkGray
        achievementsLabel.position = CGPoint(x: 0, y: -90)
        statsContainer.addChild(achievementsLabel)
        
        // Achievement badges
        let achievements = getAchievements()
        for (index, achievement) in achievements.enumerated() {
            let yPosition = -130 - (index * 35)
            
            let achievementNode = SKLabelNode(fontNamed: "AvenirNext-Regular")
            achievementNode.text = achievement
            achievementNode.fontSize = 16
            achievementNode.fontColor = .systemBlue
            achievementNode.position = CGPoint(x: 0, y: yPosition)
            statsContainer.addChild(achievementNode)
        }
        
        // Close button
        let closeButton = SKSpriteNode.roundedRect(color: .systemRed, size: CGSize(width: 120, height: 50), cornerRadius: 25)
        closeButton.position = CGPoint(x: 0, y: -230)
        closeButton.name = "closeButton"
        
        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.text = "Close"
        closeLabel.fontSize = 18
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
        
        statsContainer.addChild(closeButton)
        
        // Animate in
        statsContainer.setScale(0.1)
        statsContainer.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    private func getAchievements() -> [String] {
        let settings = GameSettings.shared
        var achievements: [String] = []
        
        if settings.currentLevel >= 5 {
            achievements.append("🎯 Level 5 Master")
        }
        
        if settings.currentLevel >= 10 {
            achievements.append("🌟 Level 10 Expert")
        }
        
        if settings.correctMatches >= 50 {
            achievements.append("🎨 Color Master")
        }
        
        if settings.getAccuracy() >= 90.0 {
            achievements.append("💯 Perfect Player")
        }
        
        if settings.totalScore >= 1000 {
            achievements.append("💰 High Scorer")
        }
        
        if achievements.isEmpty {
            achievements.append("Keep playing to earn achievements!")
        }
        
        return achievements
    }
    
    func hide() {
        guard isActive else { return }
        
        isActive = false
        
        // Animate out
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Touch Handling
    func handleTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "closeButton" {
            SoundManager.shared.playTapSound()
            hide()
            delegate?.statsScreenDidClose()
        }
    }
} 