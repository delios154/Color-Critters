//
//  EnhancedStatsScreen.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

protocol EnhancedStatsScreenDelegate: AnyObject {
    func statsScreenDidClose()
}

class EnhancedStatsScreen: SKNode {
    
    weak var delegate: EnhancedStatsScreenDelegate?
    var isActive = false
    private var currentTab = 0
    private var contentArea: SKNode!
    
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
        let statsContainer = SKSpriteNode.roundedRect(color: .white, size: CGSize(width: 380, height: 550), cornerRadius: 25)
        statsContainer.position = CGPoint(x: (self.scene?.size.width ?? 0) / 2, y: (self.scene?.size.height ?? 0) / 2)
        addChild(statsContainer)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "🎮 Game Center"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .darkGray
        titleLabel.position = CGPoint(x: 0, y: 230)
        statsContainer.addChild(titleLabel)
        
        // Create tabbed interface
        createTabbedInterface(statsContainer)
        
        // Add close button
        addCloseButton(statsContainer)
    }
    
    private func createTabbedInterface(_ container: SKSpriteNode) {
        // Tab buttons
        let tabWidth: CGFloat = 110
        let tabHeight: CGFloat = 35
        let tabY: CGFloat = 190
        
        let tabs = [("Stats", "📊"), ("Achievements", "🏆"), ("Challenges", "🎯")]
        
        for (index, (title, icon)) in tabs.enumerated() {
            let tabButton = SKSpriteNode.roundedRect(
                color: index == currentTab ? .systemBlue : .lightGray,
                size: CGSize(width: tabWidth, height: tabHeight),
                cornerRadius: 15
            )
            tabButton.position = CGPoint(x: CGFloat(index - 1) * (tabWidth + 10), y: tabY)
            tabButton.name = "tab_\(index)"
            container.addChild(tabButton)
            
            let tabLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            tabLabel.text = "\(icon) \(title)"
            tabLabel.fontSize = 13
            tabLabel.fontColor = index == currentTab ? .white : .darkGray
            tabLabel.verticalAlignmentMode = .center
            tabButton.addChild(tabLabel)
        }
        
        // Content area
        contentArea = SKNode()
        contentArea.name = "contentArea"
        container.addChild(contentArea)
        
        // Show initial tab (Stats)
        showCurrentTab()
    }
    
    private func showCurrentTab() {
        switch currentTab {
        case 0: showStatsTab()
        case 1: showAchievementsTab()
        case 2: showChallengesTab()
        default: showStatsTab()
        }
    }
    
    private func showStatsTab() {
        contentArea.removeAllChildren()
        
        let settings = GameSettings.shared
        let stats = [
            ("Player Level", "⭐ Lv.\(settings.playerLevel)"),
            ("Experience", "\(settings.experiencePoints) XP"),
            ("Current Level", "Level \(settings.currentLevel)"),
            ("Total Score", "\(settings.totalScore)"),
            ("High Score", "🏆 \(settings.highScore)"),
            ("Current Streak", "🔥 \(settings.currentStreak)"),
            ("Best Streak", "🚀 \(settings.bestStreak)"),
            ("Multiplier", "⚡ x\(String(format: "%.1f", settings.streakMultiplier))"),
            ("Coins", "🪙 \(settings.coins)"),
            ("Gems", "💎 \(settings.gems)"),
            ("Accuracy", String(format: "%.1f%%", settings.getAccuracy()))
        ]
        
        for (index, (label, value)) in stats.enumerated() {
            let yPosition = CGFloat(140 - index * 25)
            
            // Label
            let labelNode = SKLabelNode(fontNamed: "AvenirNext-Regular")
            labelNode.text = label
            labelNode.fontSize = 15
            labelNode.fontColor = .darkGray
            labelNode.horizontalAlignmentMode = .left
            labelNode.position = CGPoint(x: -160, y: yPosition)
            contentArea.addChild(labelNode)
            
            // Value
            let valueNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
            valueNode.text = value
            valueNode.fontSize = 15
            valueNode.fontColor = .black
            valueNode.horizontalAlignmentMode = .right
            valueNode.position = CGPoint(x: 160, y: yPosition)
            contentArea.addChild(valueNode)
        }
    }
    
    private func showAchievementsTab() {
        contentArea.removeAllChildren()
        
        let settings = GameSettings.shared
        let unlockedAchievements = settings.unlockedAchievements
        
        let allAchievements = [
            ("streak_5", "5 Streak Master", "🔥", "Get a 5-color streak"),
            ("streak_10", "Fire Walker", "🚀", "Get a 10-color streak"),
            ("streak_20", "Legendary", "🏆", "Get a 20-color streak"),
            ("score_1000", "High Scorer", "⭐", "Score 1000 points"),
            ("score_5000", "Champion", "🎆", "Score 5000 points"),
            ("accuracy_90", "Precision Master", "🎯", "90% accuracy with 50+ matches")
        ]
        
        let columns = 2
        let achievementWidth: CGFloat = 140
        let achievementHeight: CGFloat = 80
        
        for (index, (id, title, icon, description)) in allAchievements.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let x = CGFloat(col - columns/2) * (achievementWidth + 20) + achievementWidth/2
            let y = CGFloat(120 - row * 90)
            
            let isUnlocked = unlockedAchievements.contains(id)
            let achievementCard = createAchievementCard(
                title: title,
                icon: icon,
                description: description,
                isUnlocked: isUnlocked,
                position: CGPoint(x: x, y: y)
            )
            
            contentArea.addChild(achievementCard)
        }
        
        // Achievement stats
        let unlockedCount = unlockedAchievements.count
        let totalCount = allAchievements.count
        let progressLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        progressLabel.text = "Unlocked: \(unlockedCount)/\(totalCount) 🏅"
        progressLabel.fontSize = 16
        progressLabel.fontColor = .systemBlue
        progressLabel.position = CGPoint(x: 0, y: -120)
        contentArea.addChild(progressLabel)
    }
    
    private func showChallengesTab() {
        contentArea.removeAllChildren()
        
        let challengeManager = DailyChallengeManager.shared
        let challenges = challengeManager.getCurrentChallenges()
        
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Today's Challenges"
        titleLabel.fontSize = 18
        titleLabel.fontColor = .darkGray
        titleLabel.position = CGPoint(x: 0, y: 130)
        contentArea.addChild(titleLabel)
        
        for (index, challenge) in challenges.enumerated() {
            let yPosition = CGFloat(80 - index * 60)
            
            let challengeCard = createChallengeCard(
                challenge: challenge,
                position: CGPoint(x: 0, y: yPosition)
            )
            
            contentArea.addChild(challengeCard)
        }
        
        // Show completion stats and rewards
        let (completed, total) = challengeManager.getCompletionStats()
        let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statsLabel.text = "Progress: \(completed)/\(total) ✨"
        statsLabel.fontSize = 16
        statsLabel.fontColor = .systemGreen
        statsLabel.position = CGPoint(x: 0, y: -100)
        contentArea.addChild(statsLabel)
        
        let rewardsEarned = challengeManager.getTotalRewardsEarned()
        if rewardsEarned.coins > 0 || rewardsEarned.gems > 0 || rewardsEarned.xp > 0 {
            let rewardsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            rewardsLabel.text = "Earned: 🪙\(rewardsEarned.coins) 💎\(rewardsEarned.gems) ⚡\(rewardsEarned.xp)XP"
            rewardsLabel.fontSize = 14
            rewardsLabel.fontColor = .systemPurple
            rewardsLabel.position = CGPoint(x: 0, y: -125)
            contentArea.addChild(rewardsLabel)
        }
    }
    
    private func createAchievementCard(title: String, icon: String, description: String, isUnlocked: Bool, position: CGPoint) -> SKNode {
        let card = SKNode()
        card.position = position
        
        let background = SKSpriteNode.roundedRect(
            color: isUnlocked ? .systemYellow.withAlphaComponent(0.3) : .systemGray.withAlphaComponent(0.2),
            size: CGSize(width: 130, height: 70),
            cornerRadius: 10
        )
        card.addChild(background)
        
        let iconLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        iconLabel.text = isUnlocked ? icon : "🔒"
        iconLabel.fontSize = 20
        iconLabel.position = CGPoint(x: 0, y: 15)
        card.addChild(iconLabel)
        
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = title
        titleLabel.fontSize = 10
        titleLabel.fontColor = isUnlocked ? .black : .gray
        titleLabel.position = CGPoint(x: 0, y: -5)
        card.addChild(titleLabel)
        
        let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        descLabel.text = description
        descLabel.fontSize = 8
        descLabel.fontColor = isUnlocked ? .darkGray : .lightGray
        descLabel.position = CGPoint(x: 0, y: -20)
        card.addChild(descLabel)
        
        return card
    }
    
    private func createChallengeCard(challenge: DailyChallenge, position: CGPoint) -> SKNode {
        let card = SKNode()
        card.position = position
        
        let background = SKSpriteNode.roundedRect(
            color: challenge.isCompleted ? .systemGreen.withAlphaComponent(0.3) : .systemBlue.withAlphaComponent(0.2),
            size: CGSize(width: 300, height: 45),
            cornerRadius: 10
        )
        card.addChild(background)
        
        let iconLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        iconLabel.text = challenge.type.icon
        iconLabel.fontSize = 18
        iconLabel.position = CGPoint(x: -130, y: 5)
        card.addChild(iconLabel)
        
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = challenge.type.title
        titleLabel.fontSize = 13
        titleLabel.fontColor = .black
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: -105, y: 8)
        card.addChild(titleLabel)
        
        let progressLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        progressLabel.text = "\(challenge.progressText) - 🪙\(challenge.reward.coins) 💎\(challenge.reward.gems)"
        progressLabel.fontSize = 11
        progressLabel.fontColor = .darkGray
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.position = CGPoint(x: -105, y: -10)
        card.addChild(progressLabel)
        
        let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statusLabel.text = challenge.isCompleted ? "✅" : "⏳"
        statusLabel.fontSize = 16
        statusLabel.position = CGPoint(x: 130, y: 0)
        card.addChild(statusLabel)
        
        return card
    }
    
    private func addCloseButton(_ container: SKSpriteNode) {
        let closeButton = SKSpriteNode.roundedRect(color: .systemRed, size: CGSize(width: 45, height: 45), cornerRadius: 22.5)
        closeButton.position = CGPoint(x: 150, y: -240)
        closeButton.name = "closeButton"
        container.addChild(closeButton)
        
        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.text = "✕"
        closeLabel.fontSize = 20
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "closeButton" {
            hideStats()
        } else if let nodeName = touchedNode.name, nodeName.hasPrefix("tab_") {
            if let tabIndex = Int(String(nodeName.dropFirst(4))) {
                switchToTab(tabIndex)
            }
        }
    }
    
    private func switchToTab(_ tabIndex: Int) {
        guard tabIndex != currentTab, tabIndex >= 0, tabIndex < 3 else { return }
        
        currentTab = tabIndex
        
        // Update tab button colors
        if let parent = contentArea.parent {
            for i in 0..<3 {
                if let tabButton = parent.childNode(withName: "tab_\(i)") as? SKSpriteNode {
                    tabButton.color = i == currentTab ? .systemBlue : .lightGray
                    
                    if let tabLabel = tabButton.children.first as? SKLabelNode {
                        tabLabel.fontColor = i == currentTab ? .white : .darkGray
                    }
                }
            }
        }
        
        // Show new tab content
        showCurrentTab()
    }
    
    func hideStats() {
        guard isActive else { return }
        
        isActive = false
        removeAllChildren()
        isHidden = true
        
        delegate?.statsScreenDidClose()
    }
    
    func handleTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "closeButton" {
            SoundManager.shared.playTapSound()
            hideStats()
        }
    }
}