//
//  MiniGameManager.swift
//  Color Critters!
//
//  Created for managing mini-games between levels
//

import SpriteKit
import GameplayKit

protocol MiniGameDelegate: AnyObject {
    func miniGameCompleted(score: Int, coins: Int)
    func miniGameSkipped()
}

class MiniGameManager: SKNode {
    weak var delegate: MiniGameDelegate?
    
    private var currentGame: MiniGameType?
    private var gameScore: Int = 0
    private var gameTimer: Timer?
    private var timeRemaining: Int = 30
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shouldShowMiniGame(level: Int) -> Bool {
        // Show mini-game every 5 levels, starting from level 5
        return level > 0 && level % 5 == 0
    }
    
    func startRandomMiniGame(screenSize: CGSize) {
        let games: [MiniGameType] = [.colorMemory, .speedTap, .colorMatch, .sequenceFollow]
        currentGame = games.randomElement()
        
        guard let game = currentGame else { return }
        
        setupGameBackground(screenSize: screenSize)
        
        switch game {
        case .colorMemory:
            startColorMemoryGame(screenSize: screenSize)
        case .speedTap:
            startSpeedTapGame(screenSize: screenSize)
        case .colorMatch:
            startColorMatchGame(screenSize: screenSize)
        case .sequenceFollow:
            startSequenceFollowGame(screenSize: screenSize)
        }
        
        startGameTimer()
    }
    
    private func setupGameBackground(screenSize: CGSize) {
        // Background overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.9), size: screenSize)
        overlay.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        overlay.zPosition = 100
        addChild(overlay)
        
        // Game container
        let container = SKSpriteNode.roundedRect(color: .white, size: CGSize(width: 350, height: 450), cornerRadius: 25)
        container.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        container.zPosition = 101
        container.name = "gameContainer"
        addChild(container)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = currentGame?.title ?? "Mini Game"
        title.fontSize = 24
        title.fontColor = .darkGray
        title.position = CGPoint(x: 0, y: 180)
        container.addChild(title)
        
        // Timer
        let timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timerLabel.text = "⏰ \(timeRemaining)s"
        timerLabel.fontSize = 18
        timerLabel.fontColor = .systemRed
        timerLabel.position = CGPoint(x: 0, y: 150)
        timerLabel.name = "timerLabel"
        container.addChild(timerLabel)
        
        // Score
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .systemBlue
        scoreLabel.position = CGPoint(x: 0, y: 120)
        scoreLabel.name = "scoreLabel"
        container.addChild(scoreLabel)
        
        // Skip button
        let skipButton = SKSpriteNode.roundedRect(color: .systemGray, size: CGSize(width: 80, height: 30), cornerRadius: 15)
        skipButton.position = CGPoint(x: 120, y: -200)
        skipButton.name = "skipMiniGame"
        container.addChild(skipButton)
        
        let skipLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        skipLabel.text = "Skip"
        skipLabel.fontSize = 14
        skipLabel.fontColor = .white
        skipLabel.verticalAlignmentMode = .center
        skipButton.addChild(skipLabel)
    }
    
    // MARK: - Color Memory Game
    
    private func startColorMemoryGame(screenSize: CGSize) {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        // Instructions
        let instructions = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructions.text = "Remember the color sequence!"
        instructions.fontSize = 16
        instructions.fontColor = .darkGray
        instructions.position = CGPoint(x: 0, y: 90)
        instructions.name = "instructions"
        container.addChild(instructions)
        
        // Color grid (2x2)
        let colors: [UIColor] = [.red, .blue, .green, .yellow]
        let gridSize: CGFloat = 60
        let gridSpacing: CGFloat = 80
        
        for (index, color) in colors.enumerated() {
            let row = index / 2
            let col = index % 2
            let x = CGFloat(col - 1) * gridSpacing + gridSpacing/2
            let y = CGFloat(1 - row) * gridSpacing - 20
            
            let colorButton = SKSpriteNode.roundedRect(color: color, size: CGSize(width: gridSize, height: gridSize), cornerRadius: 8)
            colorButton.position = CGPoint(x: x, y: y)
            colorButton.name = "colorButton_\(index)"
            container.addChild(colorButton)
        }
        
        // Start sequence
        showColorSequence()
    }
    
    private func showColorSequence() {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        let sequence = generateRandomSequence(length: 4)
        var delay: TimeInterval = 1.0
        
        for colorIndex in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let button = container.childNode(withName: "colorButton_\(colorIndex)") as? SKSpriteNode {
                    let flash = SKAction.sequence([
                        SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.3),
                        SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.3)
                    ])
                    button.run(flash)
                }
            }
            delay += 0.8
        }
        
        // Enable input after sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            if let instructions = container.childNode(withName: "instructions") as? SKLabelNode {
                instructions.text = "Tap the colors in order!"
            }
        }
    }
    
    // MARK: - Speed Tap Game
    
    private func startSpeedTapGame(screenSize: CGSize) {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        let instructions = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructions.text = "Tap the circles as fast as you can!"
        instructions.fontSize = 16
        instructions.fontColor = .darkGray
        instructions.position = CGPoint(x: 0, y: 90)
        container.addChild(instructions)
        
        spawnSpeedTapCircle()
    }
    
    private func spawnSpeedTapCircle() {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple]
        let circle = SKSpriteNode.roundedRect(color: colors.randomElement() ?? .red, 
                                             size: CGSize(width: 50, height: 50), 
                                             cornerRadius: 25)
        
        let x = CGFloat.random(in: -120...120)
        let y = CGFloat.random(in: -80...40)
        circle.position = CGPoint(x: x, y: y)
        circle.name = "tapCircle"
        container.addChild(circle)
        
        // Auto-remove after 2 seconds
        circle.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
        
        // Spawn next circle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.spawnSpeedTapCircle()
        }
    }
    
    // MARK: - Color Match Game
    
    private func startColorMatchGame(screenSize: CGSize) {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        let instructions = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructions.text = "Match the target color!"
        instructions.fontSize = 16
        instructions.fontColor = .darkGray
        instructions.position = CGPoint(x: 0, y: 90)
        container.addChild(instructions)
        
        generateColorMatchPuzzle()
    }
    
    private func generateColorMatchPuzzle() {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        // Remove old puzzle
        container.enumerateChildNodes(withName: "//matchTarget*") { node, _ in
            node.removeFromParent()
        }
        container.enumerateChildNodes(withName: "//matchOption*") { node, _ in
            node.removeFromParent()
        }
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple]
        let targetColor = colors.randomElement() ?? .red
        
        // Target color
        let target = SKSpriteNode.roundedRect(color: targetColor, size: CGSize(width: 80, height: 80), cornerRadius: 8)
        target.position = CGPoint(x: 0, y: 20)
        target.name = "matchTarget"
        container.addChild(target)
        
        // Create options (including correct answer)
        var options = [targetColor]
        while options.count < 4 {
            let randomColor = colors.randomElement() ?? .red
            if !options.contains(randomColor) {
                options.append(randomColor)
            }
        }
        options.shuffle()
        
        // Display options
        for (index, color) in options.enumerated() {
            let option = SKSpriteNode.roundedRect(color: color, size: CGSize(width: 60, height: 60), cornerRadius: 8)
            let x = CGFloat(index - 2) * 70 + 35
            option.position = CGPoint(x: x, y: -60)
            option.name = "matchOption_\(index)"
            option.userData = NSMutableDictionary()
            option.userData?["isCorrect"] = color == targetColor
            container.addChild(option)
        }
    }
    
    // MARK: - Sequence Follow Game
    
    private func startSequenceFollowGame(screenSize: CGSize) {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        let instructions = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructions.text = "Follow the sequence!"
        instructions.fontSize = 16
        instructions.fontColor = .darkGray
        instructions.position = CGPoint(x: 0, y: 90)
        container.addChild(instructions)
        
        // Create arrow buttons
        let directions = ["↑", "↓", "←", "→"]
        for (index, arrow) in directions.enumerated() {
            let button = SKSpriteNode.roundedRect(color: .systemBlue, size: CGSize(width: 60, height: 60), cornerRadius: 8)
            let x = CGFloat(index - 2) * 70 + 35
            button.position = CGPoint(x: x, y: -20)
            button.name = "arrowButton_\(index)"
            container.addChild(button)
            
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = arrow
            label.fontSize = 24
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            button.addChild(label)
        }
        
        showArrowSequence()
    }
    
    private func showArrowSequence() {
        guard let container = childNode(withName: "gameContainer") else { return }
        
        let sequence = generateRandomSequence(length: 3)
        var delay: TimeInterval = 1.0
        
        for arrowIndex in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let button = container.childNode(withName: "arrowButton_\(arrowIndex)") as? SKSpriteNode {
                    let flash = SKAction.sequence([
                        SKAction.colorize(with: .yellow, colorBlendFactor: 0.7, duration: 0.4),
                        SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.4)
                    ])
                    button.run(flash)
                }
            }
            delay += 0.8
        }
    }
    
    // MARK: - Game Management
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeRemaining -= 1
            self.updateTimer()
            
            if self.timeRemaining <= 0 {
                self.endMiniGame()
            }
        }
    }
    
    private func updateTimer() {
        if let timerLabel = childNode(withName: "gameContainer")?.childNode(withName: "timerLabel") as? SKLabelNode {
            timerLabel.text = "⏰ \(timeRemaining)s"
        }
    }
    
    private func updateScore(_ points: Int) {
        gameScore += points
        if let scoreLabel = childNode(withName: "gameContainer")?.childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "Score: \(gameScore)"
        }
    }
    
    func handleTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "skipMiniGame" || touchedNode.parent?.name == "skipMiniGame" {
            skipMiniGame()
            return
        }
        
        guard let game = currentGame else { return }
        
        switch game {
        case .speedTap:
            if touchedNode.name == "tapCircle" {
                touchedNode.removeFromParent()
                updateScore(10)
                HapticManager.shared.buttonTap()
            }
            
        case .colorMatch:
            if touchedNode.name?.hasPrefix("matchOption_") == true {
                if let isCorrect = touchedNode.userData?["isCorrect"] as? Bool, isCorrect {
                    updateScore(20)
                    generateColorMatchPuzzle()
                    HapticManager.shared.correctMatch()
                } else {
                    HapticManager.shared.wrongMatch()
                }
            }
            
        default:
            break
        }
    }
    
    private func endMiniGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        let coins = gameScore / 10
        delegate?.miniGameCompleted(score: gameScore, coins: coins)
        
        removeAllChildren()
        removeFromParent()
    }
    
    private func skipMiniGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        delegate?.miniGameSkipped()
        
        removeAllChildren()
        removeFromParent()
    }
    
    // MARK: - Utilities
    
    private func generateRandomSequence(length: Int) -> [Int] {
        var sequence: [Int] = []
        for _ in 0..<length {
            sequence.append(Int.random(in: 0...3))
        }
        return sequence
    }
}

// MARK: - Mini Game Types

enum MiniGameType {
    case colorMemory
    case speedTap
    case colorMatch
    case sequenceFollow
    
    var title: String {
        switch self {
        case .colorMemory: return "Memory Test"
        case .speedTap: return "Speed Tap"
        case .colorMatch: return "Color Match"
        case .sequenceFollow: return "Follow Me"
        }
    }
}