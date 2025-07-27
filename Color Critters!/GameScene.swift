//
//  GameScene.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, AdManagerDelegate, AnimalGalleryDelegate, MiniGameDelegate {
    
    // MARK: - Game Properties
    private var currentLevel = 1
    private var score = 0
    private var correctMatches = 0
    private var totalMatches = 0
    private var gamePaused = false
    
    // MARK: - UI Elements
    private var scoreLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var critterNode: SKNode!
    private var colorBlobs: [SKSpriteNode] = []
    private var targetColor: UIColor!
    private var backgroundNode: SKSpriteNode!
    private var pauseButton: SKSpriteNode!
    private var pauseMenu: SKNode!
    private var tutorialOverlay: TutorialOverlay?
    
    // MARK: - Gamification UI Elements
    private var streakLabel: SKLabelNode!
    private var multiplierLabel: SKLabelNode!
    private var coinsLabel: SKLabelNode!
    private var gemsLabel: SKLabelNode!
    private var xpLabel: SKLabelNode!
    private var playerLevelLabel: SKLabelNode!
    private var achievementPopup: SKNode?
    private var comboEffect: SKNode?
    private var powerUpUI: PowerUpUI!
    private var enhancedStatsScreen: EnhancedStatsScreen?
    
    // MARK: - New Interactive Features
    private var comboLabel: SKLabelNode!
    private var animalGallery: AnimalGallery?
    private var miniGameManager: MiniGameManager?
    private var currentAnimalName: String = "frog"
    
    // MARK: - Game State
    private var isDragging = false
    private var draggedNode: SKSpriteNode?
    private var originalPosition: CGPoint?
    
    // MARK: - Audio
    private var correctSound: SKAction!
    private var wrongSound: SKAction!
    private var backgroundMusic: SKAudioNode?
    
    // MARK: - Critter Data
    private let critters = [
        "frog", "cat", "dog", "rabbit", "elephant", "giraffe", "lion", "tiger", "bear", "penguin"
    ]
    
    private let colors: [UIColor] = [
        .red, .blue, .green, .yellow, .orange, .purple, .systemPink, .brown, .cyan, .magenta
    ]
    
    // Test function to verify colors
    private func testColors() {
        print("Testing color definitions:")
        for (index, color) in colors.enumerated() {
            let name = colorName(for: color)
            print("  Color \(index): \(name)")
        }
        
        // Test color matching
        print("Testing color matching:")
        for i in 0..<colors.count {
            for j in 0..<colors.count {
                let color1 = colors[i]
                let color2 = colors[j]
                let isMatch = isSameColor(color1, color2)
                if isMatch {
                    print("  \(colorName(for: color1)) matches \(colorName(for: color2)): \(isMatch)")
                }
            }
        }
    }
    
    // MARK: - Animation Properties
    private var critterIdleAnimation: SKAction!
    private var blobBounceAnimation: SKAction!
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        // Generate animal images if needed (for development)
        #if DEBUG
        GenerateAnimalImages.saveImagesToDocuments()
        #endif
        
        setupGame()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Optimize scene performance
        PerformanceManager.shared.optimizeScene(self)
        
        // Preload assets for better performance
        PerformanceManager.shared.preloadGameAssets {
            // Ensure proper scene setup after view is ready
            if self.critterNode == nil {
                self.setupGame()
            }
        }
        
        // Configure accessibility
        AccessibilityManager.shared.configureForGuidedAccess(scene: self)
    }
    
    private func setupGame() {
        // Load saved game state
        loadGameState()
        
        // Test colors
        testColors()
        
        // Setup background
        setupBackground()
        
        // Setup UI
        setupUI()
        
        // Setup audio
        setupAudio()
        
        // Setup animations
        setupAnimations()
        
        // Setup ads
        setupAds()
        
        // Start level
        startNewLevel()
        
        // Start tutorial if needed
        startTutorialIfNeeded()
    }
    
    private func loadGameState() {
        let settings = GameSettings.shared
        currentLevel = settings.currentLevel
        score = settings.totalScore
        correctMatches = settings.correctMatches
        totalMatches = settings.totalMatches
        
        // Ensure we start at least at level 1
        if currentLevel < 1 {
            currentLevel = 1
        }
    }
    
    private func setupBackground() {
        // Create gradient background
        let gradient = SKSpriteNode(color: UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0), size: self.size)
        gradient.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gradient.zPosition = -100
        addChild(gradient)
        
        // Add some decorative elements
        for i in 0..<8 {
            let cloud = SKSpriteNode(color: UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.4), size: CGSize(width: 80, height: 50))
            cloud.position = CGPoint(x: CGFloat.random(in: 50...self.size.width-50), 
                                   y: CGFloat.random(in: self.size.height*0.6...self.size.height-50))
            cloud.zPosition = -50
            cloud.alpha = 0.7
            cloud.name = "cloud_\(i)"
            addChild(cloud)
            
            // Add gentle floating animation
            let floatAction = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -10...10), duration: 3.0),
                SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -10...10), duration: 3.0)
            ])
            cloud.run(SKAction.repeatForever(floatAction))
        }
    }
    
    private func setupUI() {
        let settings = GameSettings.shared
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .darkGray
        scoreLabel.position = CGPoint(x: 120, y: self.size.height - 60)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        // Level label
        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelLabel.text = "Level \(currentLevel)"
        levelLabel.fontSize = 24
        levelLabel.fontColor = .darkGray
        levelLabel.position = CGPoint(x: self.size.width - 120, y: self.size.height - 60)
        levelLabel.zPosition = 10
        addChild(levelLabel)
        
        // Gamification UI - Top HUD
        setupGamificationUI()
        
        // Collection button (gallery)
        let collectionButton = SKSpriteNode.roundedRect(color: .systemPurple, size: CGSize(width: 50, height: 50), cornerRadius: 25)
        collectionButton.position = CGPoint(x: 50, y: self.size.height - 40)
        collectionButton.zPosition = 15
        collectionButton.name = "collectionButton"
        
        let collectionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        collectionLabel.text = "📚"
        collectionLabel.fontSize = 20
        collectionLabel.fontColor = .white
        collectionLabel.verticalAlignmentMode = .center
        collectionButton.addChild(collectionLabel)
        addChild(collectionButton)
        
        // Pause button
        pauseButton = SKSpriteNode.roundedRect(color: .systemBlue, size: CGSize(width: 50, height: 50), cornerRadius: 25)
        pauseButton.position = CGPoint(x: self.size.width - 40, y: self.size.height - 40)
        pauseButton.zPosition = 15
        pauseButton.name = "pauseButton"
        
        let pauseLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pauseLabel.text = "⏸"
        pauseLabel.fontSize = 24
        pauseLabel.fontColor = .white
        pauseLabel.verticalAlignmentMode = .center
        pauseButton.addChild(pauseLabel)
        
        addChild(pauseButton)
        
        // Setup pause menu (initially hidden)
        setupPauseMenu()
        
        // Setup power-up UI
        setupPowerUpUI()
    }
    
    private func setupGamificationUI() {
        let settings = GameSettings.shared
        
        // Streak counter with fire emoji for visual appeal
        streakLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        streakLabel.text = "🔥\(settings.currentStreak)"
        streakLabel.fontSize = 20
        streakLabel.fontColor = .orange
        streakLabel.position = CGPoint(x: 80, y: self.size.height - 100)
        streakLabel.zPosition = 10
        addChild(streakLabel)
        
        // Multiplier label
        multiplierLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        multiplierLabel.text = "x\(String(format: "%.1f", settings.streakMultiplier))"
        multiplierLabel.fontSize = 18
        multiplierLabel.fontColor = .systemPurple
        multiplierLabel.position = CGPoint(x: 160, y: self.size.height - 100)
        multiplierLabel.zPosition = 10
        addChild(multiplierLabel)
        
        // Coins display
        coinsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coinsLabel.text = "🪙\(settings.coins)"
        coinsLabel.fontSize = 18
        coinsLabel.fontColor = .systemYellow
        coinsLabel.position = CGPoint(x: 80, y: self.size.height - 130)
        coinsLabel.zPosition = 10
        addChild(coinsLabel)
        
        // Gems display
        gemsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemsLabel.text = "💎\(settings.gems)"
        gemsLabel.fontSize = 18
        gemsLabel.fontColor = .systemBlue
        gemsLabel.position = CGPoint(x: 160, y: self.size.height - 130)
        gemsLabel.zPosition = 10
        addChild(gemsLabel)
        
        // Player level and XP
        playerLevelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        playerLevelLabel.text = "⭐Lv.\(settings.playerLevel)"
        playerLevelLabel.fontSize = 18
        playerLevelLabel.fontColor = .systemGreen
        playerLevelLabel.position = CGPoint(x: self.size.width - 80, y: self.size.height - 100)
        playerLevelLabel.zPosition = 10
        addChild(playerLevelLabel)
        
        // XP Progress
        xpLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        let requiredXP = settings.playerLevel * 100
        let currentXP = settings.experiencePoints % 100
        xpLabel.text = "XP: \(currentXP)/\(requiredXP)"
        xpLabel.fontSize = 14
        xpLabel.fontColor = .systemGray
        xpLabel.position = CGPoint(x: self.size.width - 80, y: self.size.height - 120)
        xpLabel.zPosition = 10
        addChild(xpLabel)
        
        // Combo display
        comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        comboLabel.text = "⚡ 0x"
        comboLabel.fontSize = 20
        comboLabel.fontColor = .systemOrange
        comboLabel.position = CGPoint(x: 240, y: self.size.height - 100)
        comboLabel.zPosition = 10
        comboLabel.alpha = 0 // Hidden initially
        addChild(comboLabel)
    }
    
    private func setupPowerUpUI() {
        powerUpUI = PowerUpUI()
        powerUpUI.delegate = self
        powerUpUI.positionForScreen(size: self.size)
        addChild(powerUpUI)
    }
    
    private func setupPauseMenu() {
        pauseMenu = SKNode()
        pauseMenu.zPosition = 100
        pauseMenu.isHidden = true
        
        // Background overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.size)
        overlay.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        pauseMenu.addChild(overlay)
        
        // Menu container
        let menuContainer = SKSpriteNode.roundedRect(color: .white, size: CGSize(width: 320, height: 420), cornerRadius: 25)
        menuContainer.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        pauseMenu.addChild(menuContainer)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Game Paused"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .darkGray
        titleLabel.position = CGPoint(x: 0, y: 140)
        menuContainer.addChild(titleLabel)
        
        // Resume button
        let resumeButton = createMenuButton(text: "Resume", color: .systemGreen, position: CGPoint(x: 0, y: 60))
        resumeButton.name = "resumeButton"
        menuContainer.addChild(resumeButton)
        
        // Settings button
        let settingsButton = createMenuButton(text: "Settings", color: .systemBlue, position: CGPoint(x: 0, y: 0))
        settingsButton.name = "settingsButton"
        menuContainer.addChild(settingsButton)
        
        // Stats button
        let statsButton = createMenuButton(text: "Stats", color: .systemPurple, position: CGPoint(x: 0, y: -60))
        statsButton.name = "statsButton"
        menuContainer.addChild(statsButton)
        
        // Share button
        let shareButton = createMenuButton(text: "Share Progress", color: .systemGreen, position: CGPoint(x: 0, y: -120))
        shareButton.name = "shareButton"
        menuContainer.addChild(shareButton)
        
        // Restart button
        let restartButton = createMenuButton(text: "Restart", color: .systemOrange, position: CGPoint(x: 0, y: -180))
        restartButton.name = "restartButton"
        menuContainer.addChild(restartButton)
        
        addChild(pauseMenu)
    }
    
    private func createMenuButton(text: String, color: UIColor, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode.roundedRect(color: color, size: CGSize(width: 220, height: 55), cornerRadius: 28)
        button.position = position
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    private func setupAudio() {
        // Start background music
        SoundManager.shared.startBackgroundMusic()
    }
    
    private func setupAnimations() {
        // Critter idle animation (gentle bobbing)
        critterIdleAnimation = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 1.2),
            SKAction.moveBy(x: 0, y: -8, duration: 1.2)
        ])
        
        // Color blob bounce animation
        blobBounceAnimation = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.6),
            SKAction.scale(to: 1.0, duration: 0.6)
        ])
    }
    
    private func setupAds() {
        // Ads are disabled - no setup needed
        AdManager.shared.delegate = self
    }
    
    private func startNewLevel() {
        // Clear previous level
        clearLevel()
        
        // Update level display
        levelLabel.text = "Level \(currentLevel)"
        
        // Determine number of colors based on level
        let numberOfColors = min(3 + (currentLevel - 1) / 3, 6)
        
        // Select random critter and color
        let randomCritter = critters.randomElement() ?? "frog"
        currentAnimalName = randomCritter // Store for collection
        targetColor = colors.randomElement() ?? .red
        
        print("Starting level \(currentLevel) with \(numberOfColors) colors, critter: \(randomCritter), target color: \(colorName(for: targetColor))")
        
        // Create critter (placeholder - in real app you'd use actual critter images)
        createCritter(named: randomCritter, targetColor: targetColor)
        
        // Create color blobs
        createColorBlobs(count: numberOfColors, targetColor: targetColor)
        
        // Save current level
        GameSettings.shared.currentLevel = currentLevel
        
        print("Level setup complete - \(colorBlobs.count) blobs created")
    }
    
    private func clearLevel() {
        // Remove existing critter
        critterNode?.removeFromParent()
        critterNode = nil
        
        // Remove existing color blobs
        for blob in colorBlobs {
            blob.removeFromParent()
        }
        colorBlobs.removeAll()
    }
    
    private func createCritter(named critterName: String, targetColor: UIColor) {
        let critterSize = CGSize(width: 100, height: 100)
        
        // Create a container for both versions of the critter
        critterNode = SKNode()
        critterNode.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.65)
        critterNode.zPosition = 5
        critterNode.name = "critter"
        
        // Generate the animal image
        if let animalImage = AnimalImageGenerator.generateAnimalImage(for: critterName, size: critterSize) {
            
            // Create the colorless (gray) version - what the animal currently looks like
            if let grayImage = animalImage.tinted(with: .lightGray) {
                let grayTexture = SKTexture(image: grayImage)
                let graySprite = SKSpriteNode(texture: grayTexture)
                graySprite.position = CGPoint(x: -60, y: 0)
                graySprite.size = critterSize
                graySprite.name = "gray_critter"
                critterNode.addChild(graySprite)
                
                // Add "Current" label
                let currentLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
                currentLabel.text = "Now"
                currentLabel.fontSize = 12
                currentLabel.fontColor = .darkGray
                currentLabel.position = CGPoint(x: 0, y: -65)
                graySprite.addChild(currentLabel)
            }
            
            // Create the target colored version - what the animal should look like
            if let tintedImage = animalImage.tinted(with: targetColor) {
                let coloredTexture = SKTexture(image: tintedImage)
                let coloredSprite = SKSpriteNode(texture: coloredTexture)
                coloredSprite.position = CGPoint(x: 60, y: 0)
                coloredSprite.size = critterSize
                coloredSprite.name = "colored_critter"
                critterNode.addChild(coloredSprite)
                
                // Add "Target" label
                let targetLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
                targetLabel.text = "Goal"
                targetLabel.fontSize = 12
                targetLabel.fontColor = .darkGray
                targetLabel.position = CGPoint(x: 0, y: -65)
                coloredSprite.addChild(targetLabel)
            }
            
        } else {
            // Fallback to colored circles if image generation fails
            let grayCircle = SKSpriteNode.roundedRect(color: .lightGray, size: critterSize, cornerRadius: 50)
            grayCircle.position = CGPoint(x: -60, y: 0)
            critterNode.addChild(grayCircle)
            
            let coloredCircle = SKSpriteNode.roundedRect(color: targetColor, size: critterSize, cornerRadius: 50)
            coloredCircle.position = CGPoint(x: 60, y: 0)
            critterNode.addChild(coloredCircle)
        }
        
        // Add arrow between them
        let arrowLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        arrowLabel.text = "→"
        arrowLabel.fontSize = 24
        arrowLabel.fontColor = .darkGray
        arrowLabel.position = CGPoint(x: 0, y: -5)
        critterNode.addChild(arrowLabel)
        
        // Add critter name label
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = critterName.capitalized
        nameLabel.fontSize = 20
        nameLabel.fontColor = .darkGray
        nameLabel.position = CGPoint(x: 0, y: -90)
        critterNode.addChild(nameLabel)
        
        // Add "needs color" indicator
        let needsColorLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        needsColorLabel.text = "Help the \(critterName) become \(colorName(for: targetColor))!"
        needsColorLabel.fontSize = 16
        needsColorLabel.fontColor = .darkGray
        needsColorLabel.position = CGPoint(x: 0, y: -115)
        critterNode.addChild(needsColorLabel)
        
        // Start idle animation
        critterNode.run(SKAction.repeatForever(critterIdleAnimation))
        
        addChild(critterNode)
        
        print("Created critter: \(critterName) with target color: \(colorName(for: targetColor)) at position \(critterNode.position)")
    }
    
    private func createColorBlobs(count: Int, targetColor: UIColor) {
        let blobSize = CGSize(width: 70, height: 70)
        let spacing: CGFloat = 90
        let totalWidth = CGFloat(count) * spacing
        let startX = (self.size.width - totalWidth) / 2 + spacing / 2
        
        print("Creating \(count) color blobs for target color: \(colorName(for: targetColor))")
        
        // Create the color array for this level
        var levelColors: [UIColor] = []
        
        // Always include the target color
        levelColors.append(targetColor)
        
        // Add other random colors (excluding target color)
        let otherColors = colors.filter { $0 != targetColor }
        let shuffledOtherColors = otherColors.shuffled()
        
        // Add enough other colors to reach the desired count
        for i in 0..<(count - 1) {
            if i < shuffledOtherColors.count {
                levelColors.append(shuffledOtherColors[i])
            }
        }
        
        // Shuffle the final array so target color isn't always first
        levelColors.shuffle()
        
        print("Level colors: \(levelColors.map { colorName(for: $0) })")
        
        for i in 0..<count {
            let currentColor = levelColors[i]
            
            // Create rounded blob with shadow
            let roundedBlob = SKSpriteNode.roundedRect(color: currentColor, size: blobSize, cornerRadius: 35)
            roundedBlob.position = CGPoint(x: startX + CGFloat(i) * spacing, y: 120)
            roundedBlob.zPosition = 5
            roundedBlob.name = "colorBlob_\(i)"
            
            // Add inner glow effect
            let glowNode = SKShapeNode(circleOfRadius: 30)
            glowNode.fillColor = .white
            glowNode.alpha = 0.3
            glowNode.blendMode = .add
            roundedBlob.addChild(glowNode)
            
            // Configure accessibility
            AccessibilityManager.shared.configureColorBlobAccessibility(roundedBlob, color: colorName(for: currentColor))
            
            // Store the actual color in userData for later retrieval
            roundedBlob.userData = NSMutableDictionary()
            roundedBlob.userData?.setValue(currentColor, forKey: "actualColor")
            
            // Add shadow
            let shadow = SKSpriteNode(color: .black, size: blobSize)
            shadow.position = CGPoint(x: 3, y: -3)
            shadow.zPosition = -1
            shadow.alpha = 0.2
            roundedBlob.addChild(shadow)
            
            // Start bounce animation
            roundedBlob.run(SKAction.repeatForever(blobBounceAnimation))
            
            colorBlobs.append(roundedBlob)
            addChild(roundedBlob)
            
            print("Created blob \(i): \(colorName(for: currentColor)) at position \(roundedBlob.position)")
            print("  Blob actual color: \(colorName(for: currentColor))")
        }
        
        // Verify target color is included
        let hasTargetColor = levelColors.contains { isSameColor($0, targetColor) }
        print("Target color \(colorName(for: targetColor)) is included: \(hasTargetColor)")
    }
    
    private func colorName(for color: UIColor) -> String {
        // Extract RGB components for more accurate color identification
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Round to 2 decimal places for comparison
        let r = round(red * 100) / 100
        let g = round(green * 100) / 100
        let b = round(blue * 100) / 100
        
        print("Color components - R: \(r), G: \(g), B: \(b)")
        
        // Compare with known color values
        if r == 1.0 && g == 0.0 && b == 0.0 { return "Red" }
        if r == 0.0 && g == 0.0 && b == 1.0 { return "Blue" }
        if r == 0.0 && g == 1.0 && b == 0.0 { return "Green" }
        if r == 1.0 && g == 1.0 && b == 0.0 { return "Yellow" }
        if r == 1.0 && g == 0.5 && b == 0.0 { return "Orange" }
        if r == 0.5 && g == 0.0 && b == 0.5 { return "Purple" }
        if r == 1.0 && g == 0.18 && b == 0.33 { return "Pink" }
        if r == 0.6 && g == 0.4 && b == 0.2 { return "Brown" }
        if r == 0.0 && g == 1.0 && b == 1.0 { return "Cyan" }
        if r == 1.0 && g == 0.0 && b == 1.0 { return "Magenta" }
        
        return "Unknown Color (R:\(r), G:\(g), B:\(b))"
    }
    
    // MARK: - Tutorial and Stats Methods
    private func startTutorialIfNeeded() {
        if !GameSettings.shared.hasCompletedOnboarding {
            // Show enhanced onboarding flow for first-time users
            let onboarding = OnboardingManager(in: self) { [weak self] in
                self?.startNewLevel()
            }
            addChild(onboarding)
            GameSettings.shared.hasSeenTutorial = true
        } else if !GameSettings.shared.hasSeenTutorial {
            // Show regular tutorial for returning users
            tutorialOverlay = TutorialOverlay()
            tutorialOverlay?.delegate = self
            tutorialOverlay?.zPosition = 200
            addChild(tutorialOverlay!)
            tutorialOverlay?.startTutorial()
            
            // Add a skip tutorial button
            let skipButton = SKLabelNode(fontNamed: "AvenirNext-Regular")
            skipButton.text = "Skip Tutorial"
            skipButton.fontSize = 16
            skipButton.fontColor = .systemBlue
            skipButton.position = CGPoint(x: self.size.width - 100, y: self.size.height - 100)
            skipButton.zPosition = 201
            skipButton.name = "skipTutorialButton"
            addChild(skipButton)
        }
    }
    
    private func showStats() {
        enhancedStatsScreen = EnhancedStatsScreen()
        enhancedStatsScreen?.delegate = self
        enhancedStatsScreen?.zPosition = 150
        addChild(enhancedStatsScreen!)
        enhancedStatsScreen?.showStats()
    }
    
    private func skipTutorial() {
        tutorialOverlay?.removeFromParent()
        tutorialOverlay = nil
        
        // Remove skip button
        childNode(withName: "skipTutorialButton")?.removeFromParent()
        
        // Mark tutorial as completed
        GameSettings.shared.hasSeenTutorial = true
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        print("Touch detected at: \(location), touched node: \(touchedNode.name ?? "unknown")")
        
        // Handle level complete overlay touches
        if let overlay = childNode(withName: "levelCompleteOverlay") {
            let nodesAtPoint = nodes(at: location)
            for node in nodesAtPoint {
                if node.name == "continueButton" {
                    if let completion = overlay.userData?["completion"] as? () -> Void {
                        overlay.removeFromParent()
                        completion()
                    }
                    return
                }
            }
            return // Don't process other touches while overlay is shown
        }
        
        // Handle tutorial elements first
        if tutorialOverlay != nil && tutorialOverlay!.isActive {
            if touchedNode.name == "continueButton" {
                SoundManager.shared.playTapSound()
                tutorialOverlay?.handleTouch(at: location)
                return
            }
            
            if touchedNode.name == "skipTutorialButton" {
                SoundManager.shared.playTapSound()
                skipTutorial()
                return
            }
        }
        
        // Handle enhanced stats screen
        if enhancedStatsScreen != nil && enhancedStatsScreen!.isActive {
            if touchedNode.name == "closeButton" {
                SoundManager.shared.playTapSound()
                enhancedStatsScreen?.handleTouch(at: location)
                return
            }
        }
        
        // Handle animal gallery
        if animalGallery != nil && animalGallery!.isActive {
            animalGallery?.handleTouch(at: location)
            return
        }
        
        // Handle mini-games
        if miniGameManager != nil {
            miniGameManager?.handleTouch(at: location)
            return
        }
        
        // Handle collection button
        if touchedNode.name == "collectionButton" {
            SoundManager.shared.playTapSound()
            HapticManager.shared.buttonTap()
            showAnimalGallery()
            return
        }
        
        // Handle pause button
        if touchedNode.name == "pauseButton" {
            SoundManager.shared.playTapSound()
            HapticManager.shared.buttonTap()
            togglePause()
            return
        }
        
        // Handle pause menu buttons
        if !pauseMenu.isHidden {
            if touchedNode.name == "resumeButton" || touchedNode.name == "settingsButton" || 
               touchedNode.name == "statsButton" || touchedNode.name == "shareButton" || touchedNode.name == "restartButton" {
                handlePauseMenuTouch(at: location)
                return
            }
        }
        
        // Handle color blob dragging - this should work even during tutorial
        for blob in colorBlobs {
            if blob.contains(location) {
                print("Starting drag for blob: \(blob.name ?? "unknown")")
                startDragging(blob: blob, at: location)
                return
            }
        }
        
        print("No specific touch handler found")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging, let draggedNode = draggedNode else { return }
        let location = touch.location(in: self)
        draggedNode.position = location
        
        // Add trail effect while dragging
        if draggedNode.childNode(withName: "trailEmitter") == nil {
            if let color = draggedNode.userData?["actualColor"] as? UIColor {
                let trail = AnimationManager.shared.createTrailEffect(for: draggedNode, color: color)
                trail.name = "trailEmitter"
                draggedNode.addChild(trail)
            }
        }
        
        // Show proximity feedback
        FeedbackManager.shared.showProximityFeedback(draggedNode: draggedNode, targetNode: critterNode, in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging, let draggedNode = draggedNode else { return }
        let location = touch.location(in: self)
        
        print("Touch ended, checking for critter collision")
        
        // Check if dropped on critter
        if critterNode.contains(location) {
            print("Dropped on critter - handling color match")
            handleColorMatch(draggedNode: draggedNode)
        } else {
            print("Dropped outside critter - returning to original position")
            returnToOriginalPosition()
        }
        
        stopDragging()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch cancelled - returning to original position")
        returnToOriginalPosition()
        stopDragging()
    }
    
    private func handlePauseMenuTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        switch touchedNode.name {
        case "resumeButton":
            togglePause()
        case "settingsButton":
            showSettings()
        case "statsButton":
            showStats()
        case "shareButton":
            shareProgress()
        case "restartButton":
            restartGame()
        default:
            break
        }
    }
    
    private func togglePause() {
        gamePaused.toggle()
        
        if gamePaused {
            pauseMenu.isHidden = false
            scene?.view?.isPaused = true
        } else {
            pauseMenu.isHidden = true
            scene?.view?.isPaused = false
        }
    }
    
    private func showSettings() {
        // Simple settings implementation
        let settingsAlert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let soundAction = UIAlertAction(title: "Sound: \(SoundManager.shared.isSoundOn() ? "On" : "Off")", style: .default) { _ in
            SoundManager.shared.toggleSound()
        }
        
        let musicAction = UIAlertAction(title: "Music: \(SoundManager.shared.isMusicOn() ? "On" : "Off")", style: .default) { _ in
            SoundManager.shared.toggleMusic()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        settingsAlert.addAction(soundAction)
        settingsAlert.addAction(musicAction)
        settingsAlert.addAction(cancelAction)
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(settingsAlert, animated: true)
        }
    }
    
    private func restartGame() {
        GameSettings.shared.resetGame()
        loadGameState()
        scoreLabel.text = "Score: \(score)"
        togglePause()
        startNewLevel()
    }
    
    private func startDragging(blob: SKSpriteNode, at location: CGPoint) {
        isDragging = true
        draggedNode = blob
        originalPosition = blob.position
        
        // Visual feedback
        blob.setScale(1.3)
        blob.zPosition = 10
        
        // Haptic feedback
        HapticManager.shared.dragStart()
        
        // Stop the bounce animation while dragging
        blob.removeAllActions()
    }
    
    private func stopDragging() {
        isDragging = false
        
        // Remove trail effect
        if let trail = draggedNode?.childNode(withName: "trailEmitter") {
            trail.removeFromParent()
        }
        
        // Hide proximity feedback
        FeedbackManager.shared.hideProximityFeedback(in: self)
        
        draggedNode?.setScale(1.0)
        draggedNode?.zPosition = 5
        draggedNode = nil
        originalPosition = nil
        
        // Restart bounce animation for all blobs
        for blob in colorBlobs {
            blob.run(SKAction.repeatForever(blobBounceAnimation))
        }
    }
    
    private func returnToOriginalPosition() {
        guard let draggedNode = draggedNode, let originalPosition = originalPosition else { return }
        
        let moveAction = SKAction.move(to: originalPosition, duration: 0.3)
        moveAction.timingMode = .easeOut
        draggedNode.run(moveAction)
    }
    
    private func handleColorMatch(draggedNode: SKSpriteNode) {
        // Get the actual color from the blob's userData
        let blobColor = draggedNode.userData?.object(forKey: "actualColor") as? UIColor ?? draggedNode.color
        
        // Compare colors using a more robust method
        let isCorrect = isSameColor(blobColor, targetColor)
        
        print("Color match check:")
        print("  Dragged blob color: \(colorName(for: blobColor))")
        print("  Target color: \(colorName(for: targetColor))")
        print("  Is correct: \(isCorrect)")
        
        if isCorrect {
            handleCorrectMatch()
        } else {
            handleWrongMatch()
        }
    }
    
    private func isSameColor(_ color1: UIColor, _ color2: UIColor) -> Bool {
        // Extract RGB components for comparison
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        // Round to 2 decimal places for more consistent comparison
        let r1 = round(red1 * 100) / 100
        let g1 = round(green1 * 100) / 100
        let b1 = round(blue1 * 100) / 100
        
        let r2 = round(red2 * 100) / 100
        let g2 = round(green2 * 100) / 100
        let b2 = round(blue2 * 100) / 100
        
        // Compare with some tolerance for floating point precision
        let tolerance: CGFloat = 0.05
        let redMatch = abs(r1 - r2) < tolerance
        let greenMatch = abs(g1 - g2) < tolerance
        let blueMatch = abs(b1 - b2) < tolerance
        
        print("Color comparison - Color1: R:\(r1), G:\(g1), B:\(b1) vs Color2: R:\(r2), G:\(g2), B:\(b2)")
        print("  Red match: \(redMatch), Green match: \(greenMatch), Blue match: \(blueMatch)")
        
        return redMatch && greenMatch && blueMatch
    }
    
    private func handleCorrectMatch() {
        let settings = GameSettings.shared
        let powerManager = PowerUpManager.shared
        let challengeManager = DailyChallengeManager.shared
        let comboManager = ComboManager.shared
        let oldStreak = settings.currentStreak
        
        // Add to combo chain
        comboManager.addCorrectAnswer()
        
        // Play correct sound and haptic feedback
        SoundManager.shared.playCorrectSound()
        HapticManager.shared.correctMatch()
        
        // Enhanced visual feedback with particle effects
        if let critter = critterNode {
            AnimationManager.shared.createColorSplash(at: critter.position, in: self, color: targetColor)
            AnimationManager.shared.celebrateSuccess(at: critter.position, in: self)
            
            // Animate the critter with elastic scaling
            critter.run(AnimationManager.shared.elasticScale(to: 1.2, duration: 0.4)) {
                critter.run(SKAction.scale(to: 1.0, duration: 0.2))
            }
        }
        
        // Add animal to collection
        AnimalCollectionManager.shared.addAnimal(name: currentAnimalName, color: targetColor, level: currentLevel)
        
        // Accessibility announcement
        AccessibilityManager.shared.announceSuccess(critterName: currentAnimalName, color: colorName(for: targetColor))
        
        // Check for collection rewards
        let collectionRewards = AnimalCollectionManager.shared.checkForCollectionRewards()
        for reward in collectionRewards {
            showCollectionReward(reward)
        }
        
        // Enhanced visual feedback with particle explosion
        critterNode.run(SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
        
        // Add celebration particle effect
        createCelebrationParticles(at: critterNode.position)
        
        // Transform the critter from gray to colored with special effect
        transformCritterToColored(targetColor: targetColor)
        
        // Calculate score with power-up and combo multipliers
        let baseScore = 10 * currentLevel
        let powerUpMultiplier = powerManager.getScoreMultiplier()
        let comboMultiplier = comboManager.getScoreMultiplier()
        let finalScore = Int(Double(baseScore) * powerUpMultiplier * comboMultiplier)
        
        score += finalScore
        correctMatches += 1
        totalMatches += 1
        
        // Apply coin multipliers from power-ups and combos
        let baseCoins = finalScore / 100 + 1
        let powerUpCoinMultiplier = powerManager.getCoinMultiplier()
        let comboCoinMultiplier = comboManager.getCoinMultiplier()
        let finalCoins = Int(Double(baseCoins) * powerUpCoinMultiplier * comboCoinMultiplier)
        settings.coins += finalCoins
        
        GameSettings.shared.updateScore(baseScore) // Use base score for settings
        GameSettings.shared.updateMatchStats(correct: true)
        
        // Consume power-ups
        powerManager.consumePowerUp(.scoreBoost)
        powerManager.consumePowerUp(.doubleCoins)
        
        // Update daily challenges
        challengeManager.updateColorMasterProgress()
        challengeManager.updateStreakProgress(settings.currentStreak)
        if let critterName = critters.randomElement() {
            challengeManager.updateCritterCollectorProgress(critterName)
        }
        
        // Update all gamification UI
        updateGamificationUI()
        powerUpUI?.updateUI()
        
        // Check for streak milestones and show special effects
        let newStreak = settings.currentStreak
        if newStreak > oldStreak {
            showStreakEffect(streak: newStreak)
            challengeManager.updateStreakProgress(newStreak)
            HapticManager.shared.streakMilestone()
        }
        
        // Show combo effects
        updateComboDisplay()
        if comboManager.shouldShowComboEffect() {
            showComboEffect(combo: comboManager.combo)
        }
        
        // Check for achievements
        checkForNewAchievements()
        
        // Show dynamic success message based on streak and power-ups
        let feedbackPosition = CGPoint(x: critterNode.position.x, y: critterNode.position.y + 100)
        FeedbackManager.shared.showEncouragementBubble(at: feedbackPosition, in: self)
        var successMessage = getSuccessMessage(streak: newStreak)
        if powerUpMultiplier > 1.0 {
            successMessage += " ⚡"
        }
        if powerUpCoinMultiplier > 1.0 || comboCoinMultiplier > 1.0 {
            successMessage += " 💰"
        }
        showMessage(successMessage, color: .green)
        
        // Show score popup with multiplier if active
        if powerUpMultiplier > 1.0 || powerUpCoinMultiplier > 1.0 || comboCoinMultiplier > 1.0 {
            showFloatingText("+\(finalScore) pts!", at: CGPoint(x: critterNode.position.x, y: critterNode.position.y + 60), color: .systemYellow)
        }
        
        // Play level up sound and next level after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            SoundManager.shared.playLevelUpSound()
            HapticManager.shared.levelComplete()
            
            // Calculate stars based on accuracy
            let accuracy = Double(correctMatches) / Double(max(totalMatches, 1))
            let stars = accuracy >= 0.9 ? 3 : (accuracy >= 0.7 ? 2 : 1)
            
            // Show enhanced level complete feedback
            FeedbackManager.shared.showLevelCompleteFeedback(in: self, stars: stars) {
                self.currentLevel += 1
                
                // Check for mini-game
                let miniGameManager = MiniGameManager()
                if miniGameManager.shouldShowMiniGame(level: self.currentLevel) {
                    self.showMiniGame()
                } else {
                    self.startNewLevel()
                }
            }
        }
    }
    
    private func handleWrongMatch() {
        let powerManager = PowerUpManager.shared
        let settings = GameSettings.shared
        let comboManager = ComboManager.shared
        let oldStreak = settings.currentStreak
        
        // Check for streak protection power-up
        if powerManager.hasStreakProtection() {
            // Consume streak protection but don't break streak
            powerManager.consumePowerUp(.streakProtect)
            showFloatingText("Streak Protected! 🛡️", at: CGPoint(x: size.width/2, y: size.height/2), color: .systemBlue)
            
            // Play wrong sound but don't break streak
            SoundManager.shared.playWrongSound()
            
            // Light visual feedback
            critterNode.run(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            
            totalMatches += 1
            // Don't call updateMatchStats to avoid breaking streak
            
            showMessage("Protected! Try again! 🛡️", color: .systemBlue)
        } else {
            // Normal wrong match handling
            SoundManager.shared.playWrongSound()
            HapticManager.shared.wrongMatch()
            
            // Break combo chain
            comboManager.breakCombo()
            updateComboDisplay()
            
            // Enhanced visual feedback with streak break effect
            critterNode.run(SKAction.sequence([
                SKAction.rotate(byAngle: 0.1, duration: 0.1),
                SKAction.rotate(byAngle: -0.2, duration: 0.1),
                SKAction.rotate(byAngle: 0.1, duration: 0.1)
            ]))
            
            totalMatches += 1
            GameSettings.shared.updateMatchStats(correct: false)
            
            // Show streak break notification if applicable
            if oldStreak > 0 {
                showStreakBreakEffect()
            }
            
            showMessage("Try again! 💪", color: .orange)
        }
        
        // Update gamification UI
        updateGamificationUI()
        powerUpUI?.updateUI()
        
        // Return blob to original position
        returnToOriginalPosition()
    }
    
    private func showMessage(_ text: String, color: UIColor) {
        let message = SKLabelNode(fontNamed: "AvenirNext-Bold")
        message.text = text
        message.fontSize = 28
        message.fontColor = color
        message.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
        message.zPosition = 20
        message.alpha = 0
        
        addChild(message)
        
        message.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Game update logic can be added here
    }
    
    // MARK: - AdManagerDelegate (Ads are disabled)
    func adDidFinish() {
        // Ads are disabled - no action needed
    }
    
    func adDidFail(with error: Error) {
        // Ads are disabled - no action needed
    }
    
    func rewardedAdDidComplete() {
        // Ads are disabled - no bonus needed
    }
    
    // MARK: - Gamification Helper Functions
    
    private func updateGamificationUI() {
        let settings = GameSettings.shared
        
        // Update streak display
        streakLabel.text = "🔥\(settings.currentStreak)"
        
        // Update multiplier display with color coding
        multiplierLabel.text = "x\(String(format: "%.1f", settings.streakMultiplier))"
        if settings.streakMultiplier > 1.0 {
            multiplierLabel.fontColor = .systemPurple
            // Add pulsing effect for active multipliers
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            multiplierLabel.run(pulse)
        } else {
            multiplierLabel.fontColor = .systemGray
        }
        
        // Update currency displays
        coinsLabel.text = "🪙\(settings.coins)"
        gemsLabel.text = "💎\(settings.gems)"
        
        // Update player level and XP
        playerLevelLabel.text = "⭐Lv.\(settings.playerLevel)"
        let requiredXP = settings.playerLevel * 100
        let currentXP = settings.experiencePoints % requiredXP
        xpLabel.text = "XP: \(currentXP)/\(requiredXP)"
        
        // Update score with animation
        let scoreUpdateAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        scoreLabel.run(scoreUpdateAction)
        scoreLabel.text = "Score: \(score)"
    }
    
    private func createCelebrationParticles(at position: CGPoint) {
        // Create sparkle particle effect
        let sparkleEmitter = SKEmitterNode()
        sparkleEmitter.particleTexture = SKTexture(imageNamed: "spark") // Will fall back to colored rectangle
        sparkleEmitter.particleBirthRate = 50
        sparkleEmitter.numParticlesToEmit = 30
        sparkleEmitter.particleLifetime = 1.0
        sparkleEmitter.particleLifetimeRange = 0.5
        sparkleEmitter.particlePositionRange = CGVector(dx: 50, dy: 50)
        sparkleEmitter.particleSpeed = 100
        sparkleEmitter.particleSpeedRange = 50
        sparkleEmitter.emissionAngle = 0
        sparkleEmitter.emissionAngleRange = CGFloat.pi * 2
        sparkleEmitter.particleAlpha = 1.0
        sparkleEmitter.particleAlphaRange = 0.5
        sparkleEmitter.particleScale = 0.3
        sparkleEmitter.particleScaleRange = 0.2
        sparkleEmitter.particleColor = targetColor
        sparkleEmitter.particleColorBlendFactor = 1.0
        sparkleEmitter.particleBlendMode = .add
        
        sparkleEmitter.position = position
        sparkleEmitter.zPosition = 50
        addChild(sparkleEmitter)
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sparkleEmitter.removeFromParent()
        }
        
        // Add screen shake for big celebrations
        let settings = GameSettings.shared
        if settings.currentStreak >= 5 {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            self.run(shake)
        }
    }
    
    private func showStreakEffect(streak: Int) {
        // Use enhanced feedback manager for better visual effects
        let position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        
        // Show milestone feedback for specific streak values
        if streak % 5 == 0 || streak == 3 {
            FeedbackManager.shared.showStreakMilestone(streak, at: position, in: self)
        }
        
        // Create streak milestone effects
        if streak == 3 {
            showFloatingText("STREAK x3! 🚀", at: CGPoint(x: size.width/2, y: size.height/2 + 50), color: .systemOrange)
        } else if streak == 5 {
            showFloatingText("ON FIRE! 🔥", at: CGPoint(x: size.width/2, y: size.height/2 + 50), color: .systemRed)
            createFireworksEffect()
        } else if streak == 10 {
            showFloatingText("INCREDIBLE! 🎆", at: CGPoint(x: size.width/2, y: size.height/2 + 50), color: .systemPurple)
            createFireworksEffect()
        } else if streak >= 15 {
            showFloatingText("LEGENDARY! 🏆", at: CGPoint(x: size.width/2, y: size.height/2 + 50), color: .systemYellow)
            createFireworksEffect()
        }
    }
    
    private func showStreakBreakEffect() {
        showFloatingText("Streak Broken 😢", at: CGPoint(x: size.width/2, y: size.height/2), color: .systemGray)
        
        // Add visual feedback for streak break
        let flashRed = SKAction.sequence([
            SKAction.run {
                self.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            },
            SKAction.wait(forDuration: 0.1),
            SKAction.run {
                self.backgroundColor = UIColor.clear
            }
        ])
        self.run(flashRed)
    }
    
    private func showFloatingText(_ text: String, at position: CGPoint, color: UIColor) {
        let floatingLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        floatingLabel.text = text
        floatingLabel.fontSize = 24
        floatingLabel.fontColor = color
        floatingLabel.position = position
        floatingLabel.zPosition = 100
        addChild(floatingLabel)
        
        let floatUp = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 80, duration: 1.5),
                SKAction.fadeOut(withDuration: 1.5),
                SKAction.scale(by: 1.5, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        
        floatingLabel.run(floatUp)
    }
    
    private func createFireworksEffect() {
        for i in 0..<5 {
            let firework = SKEmitterNode()
            firework.particleBirthRate = 100
            firework.numParticlesToEmit = 50
            firework.particleLifetime = 2.0
            firework.particlePositionRange = CGVector(dx: 20, dy: 20)
            firework.particleSpeed = 200
            firework.particleSpeedRange = 100
            firework.emissionAngleRange = CGFloat.pi * 2
            firework.particleScale = 0.5
            firework.particleScaleRange = 0.3
            firework.particleColor = colors.randomElement() ?? .systemRed
            firework.particleColorBlendFactor = 1.0
            firework.particleBlendMode = .add
            
            firework.position = CGPoint(
                x: CGFloat.random(in: 100...size.width-100),
                y: CGFloat.random(in: size.height*0.6...size.height*0.8)
            )
            firework.zPosition = 60
            addChild(firework)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                firework.removeFromParent()
            }
        }
    }
    
    private func getSuccessMessage(streak: Int) -> String {
        if streak >= 15 {
            return ["LEGENDARY! 🏆", "UNSTOPPABLE! ⚡", "AMAZING! 🎆"].randomElement() ?? "Great!"
        } else if streak >= 10 {
            return ["INCREDIBLE! 🚀", "FANTASTIC! 🎉", "AWESOME! ⭐"].randomElement() ?? "Great!"
        } else if streak >= 5 {
            return ["ON FIRE! 🔥", "SUPERB! 🎆", "BRILLIANT! ✨"].randomElement() ?? "Great!"
        } else if streak >= 3 {
            return ["Great streak! 🚀", "Keep going! 💪", "Nice work! 🎉"].randomElement() ?? "Great!"
        } else {
            return ["Great job! 🎉", "Well done! ✅", "Perfect! ⭐", "Excellent! 😄"].randomElement() ?? "Great!"
        }
    }
    
    private func checkForNewAchievements() {
        let settings = GameSettings.shared
        let previousAchievements = settings.unlockedAchievements
        
        // This will trigger achievement checking in GameSettings
        settings.updateMatchStats(correct: true)
        
        let newAchievements = settings.unlockedAchievements
        let earnedAchievements = newAchievements.subtracting(previousAchievements)
        
        // Show achievement popup for each new achievement
        for achievement in earnedAchievements {
            showAchievementPopup(achievement: achievement)
        }
    }
    
    private func showAchievementPopup(achievement: String) {
        let popup = SKNode()
        popup.zPosition = 200
        
        // Background
        let background = SKSpriteNode.roundedRect(color: .systemYellow, size: CGSize(width: 280, height: 100), cornerRadius: 20)
        background.position = CGPoint(x: size.width/2, y: size.height + 50)
        popup.addChild(background)
        
        // Achievement text
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "ACHIEVEMENT UNLOCKED!"
        title.fontSize = 16
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 15)
        background.addChild(title)
        
        let description = SKLabelNode(fontNamed: "AvenirNext-Medium")
        description.text = getAchievementDescription(achievement)
        description.fontSize = 14
        description.fontColor = .white
        description.position = CGPoint(x: 0, y: -15)
        background.addChild(description)
        
        addChild(popup)
        
        // Animate in and out
        let slideIn = SKAction.moveTo(y: size.height - 80, duration: 0.5)
        let wait = SKAction.wait(forDuration: 3.0)
        let slideOut = SKAction.moveTo(y: size.height + 50, duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        popup.run(SKAction.sequence([slideIn, wait, slideOut, remove]))
    }
    
    private func getAchievementDescription(_ achievement: String) -> String {
        switch achievement {
        case "streak_5": return "5 Colors in a Row! 🔥"
        case "streak_10": return "10 Colors in a Row! 🚀"
        case "streak_20": return "20 Colors in a Row! 🏆"
        case "score_1000": return "Scored 1000 Points! ⭐"
        case "score_5000": return "Scored 5000 Points! 🎆"
        case "accuracy_90": return "90% Accuracy Master! 🎯"
        default: return "New Achievement! 🏅"
        }
    }
    
    // MARK: - New Interactive Features
    
    private func showAnimalGallery() {
        animalGallery = AnimalGallery()
        animalGallery?.delegate = self
        animalGallery?.zPosition = 200
        addChild(animalGallery!)
        animalGallery?.showGallery()
    }
    
    private func showMiniGame() {
        miniGameManager = MiniGameManager()
        miniGameManager?.delegate = self
        addChild(miniGameManager!)
        miniGameManager?.startRandomMiniGame(screenSize: self.size)
    }
    
    private func updateComboDisplay() {
        let combo = ComboManager.shared.combo
        
        if combo > 1 {
            comboLabel.text = "⚡ \(combo)x"
            comboLabel.fontColor = ComboManager.shared.getComboColor()
            comboLabel.alpha = 1.0
            
            // Pulse animation for active combos
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            comboLabel.run(pulse)
        } else {
            comboLabel.alpha = 0.3
            comboLabel.text = "⚡ 0x"
            comboLabel.fontColor = .systemGray
        }
    }
    
    private func showComboEffect(combo: Int) {
        if let message = ComboManager.shared.getComboMessage() {
            showFloatingText(message, at: CGPoint(x: size.width/2, y: size.height/2 + 100), color: ComboManager.shared.getComboColor())
        }
        
        let intensity = ComboManager.shared.getComboEffectIntensity()
        
        // Screen shake for high combos
        if intensity == .high || intensity == .extreme {
            let shakeIntensity = intensity.screenShakeIntensity
            let shake = SKAction.sequence([
                SKAction.moveBy(x: shakeIntensity, y: 0, duration: 0.05),
                SKAction.moveBy(x: -shakeIntensity * 2, y: 0, duration: 0.05),
                SKAction.moveBy(x: shakeIntensity, y: 0, duration: 0.05)
            ])
            self.run(shake)
        }
    }
    
    private func showCollectionReward(_ reward: CollectionReward) {
        let message = "\(reward.title) +\(reward.coins) coins!"
        showFloatingText(message, at: CGPoint(x: size.width/2, y: size.height/2 + 150), color: .systemYellow)
        
        // Add coins to player
        GameSettings.shared.coins += reward.coins
        updateGamificationUI()
        
        HapticManager.shared.collectionComplete()
    }
    
    private func shareProgress() {
        if let viewController = self.view?.window?.rootViewController {
            SocialSharingManager.shared.shareGameStats(from: viewController)
        }
        togglePause() // Close pause menu
    }
    
    private func shareAnimalComplete() {
        if let viewController = self.view?.window?.rootViewController {
            SocialSharingManager.shared.shareColoredAnimal(currentAnimalName, color: targetColor, level: currentLevel, from: viewController)
        }
    }
}

// MARK: - AnimalGalleryDelegate
extension GameScene {
    func galleryDidClose() {
        animalGallery?.removeFromParent()
        animalGallery = nil
    }
}

// MARK: - MiniGameDelegate
extension GameScene {
    func miniGameCompleted(score: Int, coins: Int) {
        // Award bonus rewards
        GameSettings.shared.coins += coins
        GameSettings.shared.updateScore(score)
        updateGamificationUI()
        
        showFloatingText("Mini-Game Complete! +\(coins) coins!", 
                        at: CGPoint(x: size.width/2, y: size.height/2), 
                        color: .systemGreen)
        
        HapticManager.shared.levelComplete()
        
        // Continue to next level
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startNewLevel()
        }
    }
    
    func miniGameSkipped() {
        // Just continue to next level
        startNewLevel()
    }
}

// MARK: - TutorialOverlayDelegate
extension GameScene: TutorialOverlayDelegate {
    func tutorialDidComplete() {
        tutorialOverlay?.removeFromParent()
        tutorialOverlay = nil
        
        // Remove skip button
        childNode(withName: "skipTutorialButton")?.removeFromParent()
        
        GameSettings.shared.hasSeenTutorial = true
    }
}

// MARK: - EnhancedStatsScreenDelegate
extension GameScene: EnhancedStatsScreenDelegate {
    func statsScreenDidClose() {
        enhancedStatsScreen?.removeFromParent()
        enhancedStatsScreen = nil
    }
}

// MARK: - PowerUpUIDelegate
extension GameScene: PowerUpUIDelegate {
    func powerUpActivated(_ type: PowerUpType) {
        // Show activation feedback
        let message = "\(type.name) Activated! \(type.icon)"
        showFloatingText(message, at: CGPoint(x: size.width/2, y: size.height - 300), color: .systemPurple)
        
        // Play power-up sound
        SoundManager.shared.playCorrectSound() // Could add specific power-up sound
        
        // Show color hint if that power-up was activated
        if type == .colorHint {
            showColorHint()
        }
    }
    
    func powerUpShopOpened() {
        // Could implement power-up shop here
        showFloatingText("Power-up Shop Coming Soon!", at: CGPoint(x: size.width/2, y: size.height/2), color: .systemBlue)
    }
    
    private func showColorHint() {
        // Briefly highlight the correct color
        for blob in colorBlobs {
            if isSameColor(blob.color, targetColor) {
                let hint = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3),
                    SKAction.scale(to: 1.3, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
                blob.run(hint)
                
                // Add a glow effect
                let glow = SKSpriteNode(color: .systemYellow, size: CGSize(width: 80, height: 80))
                glow.alpha = 0.5
                glow.position = blob.position
                glow.zPosition = blob.zPosition - 1
                addChild(glow)
                
                let glowFade = SKAction.sequence([
                    SKAction.fadeOut(withDuration: 2.0),
                    SKAction.removeFromParent()
                ])
                glow.run(glowFade)
                
                break
            }
        }
    }
    
    private func transformCritterToColored(targetColor: UIColor) {
        // Find the gray critter and make it disappear with animation
        if let graySprite = critterNode.childNode(withName: "gray_critter") as? SKSpriteNode {
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let disappear = SKAction.group([fadeOut, scaleDown])
            graySprite.run(disappear)
        }
        
        // Find the colored critter and make it animate into place
        if let coloredSprite = critterNode.childNode(withName: "colored_critter") as? SKSpriteNode {
            // Move the colored version to the center with animation
            let moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.5)
            let scaleUp = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            let celebrate = SKAction.group([moveToCenter, scaleUp])
            
            coloredSprite.run(celebrate)
            
            // Add sparkle effect
            addSparkleEffect(to: coloredSprite)
        }
        
        // Update the arrow and hide it after animation
        for child in critterNode.children {
            if let label = child as? SKLabelNode, label.text == "→" {
                let fadeOutArrow = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
                label.run(fadeOutArrow)
                break
            }
        }
        
        // Update the instruction text
        for child in critterNode.children {
            if let label = child as? SKLabelNode, let text = label.text, text.contains("Help") {
                label.text = "Perfect! The critter is now \(colorName(for: targetColor))!"
                label.fontColor = targetColor
                break
            }
        }
    }
    
    private func addSparkleEffect(to node: SKSpriteNode) {
        // Create simple sparkle particles
        for i in 0..<8 {
            let sparkle = SKSpriteNode(color: .yellow, size: CGSize(width: 4, height: 4))
            sparkle.position = node.position
            sparkle.zPosition = 10
            
            let angle = CGFloat(i) * CGFloat.pi / 4
            let distance: CGFloat = 60
            let targetPosition = CGPoint(
                x: node.position.x + cos(angle) * distance,
                y: node.position.y + sin(angle) * distance
            )
            
            let moveOut = SKAction.move(to: targetPosition, duration: 0.5)
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
            let sparkleAction = SKAction.group([moveOut, fadeOut])
            let removeSparkle = SKAction.removeFromParent()
            let sequence = SKAction.sequence([sparkleAction, removeSparkle])
            
            critterNode.addChild(sparkle)
            sparkle.run(sequence)
        }
    }
}
