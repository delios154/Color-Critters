//
//  PowerUpUI.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

protocol PowerUpUIDelegate: AnyObject {
    func powerUpActivated(_ type: PowerUpType)
    func powerUpShopOpened()
}

class PowerUpUI: SKNode {
    
    weak var delegate: PowerUpUIDelegate?
    private var powerUpButtons: [PowerUpType: SKNode] = [:]
    private var isExpanded = false
    
    override init() {
        super.init()
        setupPowerUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPowerUpUI()
    }
    
    private func setupPowerUpUI() {
        zPosition = 20
        
        // Power-up toggle button
        let toggleButton = createToggleButton()
        addChild(toggleButton)
        
        // Power-up buttons (initially hidden)
        createPowerUpButtons()
        
        updateUI()
    }
    
    private func createToggleButton() -> SKNode {
        let button = SKNode()
        button.name = "powerUpToggle"
        button.position = CGPoint(x: 0, y: 0)
        
        let background = SKSpriteNode.roundedRect(
            color: .systemPurple,
            size: CGSize(width: 60, height: 60),
            cornerRadius: 30
        )
        button.addChild(background)
        
        let icon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        icon.text = "⚡"
        icon.fontSize = 24
        icon.fontColor = .white
        icon.verticalAlignmentMode = .center
        button.addChild(icon)
        
        return button
    }
    
    private func createPowerUpButtons() {
        let powerUpTypes = PowerUpType.allCases
        let radius: CGFloat = 80
        
        for (index, type) in powerUpTypes.enumerated() {
            let angle = (CGFloat.pi * 2 * CGFloat(index)) / CGFloat(powerUpTypes.count) - CGFloat.pi/2
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            
            let powerUpButton = createPowerUpButton(type: type, position: CGPoint(x: x, y: y))
            powerUpButton.alpha = 0
            powerUpButton.setScale(0.1)
            powerUpButtons[type] = powerUpButton
            addChild(powerUpButton)
        }
    }
    
    private func createPowerUpButton(type: PowerUpType, position: CGPoint) -> SKNode {
        let button = SKNode()
        button.name = "powerUp_\(type.rawValue)"
        button.position = position
        
        let background = SKSpriteNode.roundedRect(
            color: .systemBlue,
            size: CGSize(width: 50, height: 50),
            cornerRadius: 25
        )
        button.addChild(background)
        
        let icon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        icon.text = type.icon
        icon.fontSize = 16
        icon.fontColor = .white
        icon.verticalAlignmentMode = .center
        button.addChild(icon)
        
        // Count badge
        let countBadge = SKSpriteNode.roundedRect(
            color: .systemRed,
            size: CGSize(width: 20, height: 20),
            cornerRadius: 10
        )
        countBadge.position = CGPoint(x: 20, y: 20)
        countBadge.name = "countBadge"
        button.addChild(countBadge)
        
        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.fontSize = 10
        countLabel.fontColor = .white
        countLabel.verticalAlignmentMode = .center
        countLabel.name = "countLabel"
        countBadge.addChild(countLabel)
        
        return button
    }
    
    func updateUI() {
        let powerManager = PowerUpManager.shared
        
        for (type, button) in powerUpButtons {
            let count = powerManager.getPowerUpCount(type)
            let isActive = powerManager.isActive(type)
            
            // Update count badge
            if let countBadge = button.childNode(withName: "countBadge"),
               let countLabel = countBadge.childNode(withName: "countLabel") as? SKLabelNode {
                countLabel.text = "\(count)"
                countBadge.alpha = count > 0 ? 1.0 : 0.3
            }
            
            // Update button appearance
            if let background = button.children.first as? SKSpriteNode {
                if isActive {
                    background.color = .systemGreen
                    // Add pulsing effect
                    let pulse = SKAction.sequence([
                        SKAction.scale(to: 1.1, duration: 0.5),
                        SKAction.scale(to: 1.0, duration: 0.5)
                    ])
                    background.run(SKAction.repeatForever(pulse), withKey: "pulse")
                } else {
                    background.color = count > 0 ? .systemBlue : .systemGray
                    background.removeAction(forKey: "pulse")
                }
            }
        }
    }
    
    func toggleExpansion() {
        isExpanded.toggle()
        
        if isExpanded {
            expandPowerUps()
        } else {
            collapsePowerUps()
        }
    }
    
    private func expandPowerUps() {
        for button in powerUpButtons.values {
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
            let expand = SKAction.group([fadeIn, scaleUp])
            button.run(expand)
        }
        
        // Update toggle button
        if let toggleButton = childNode(withName: "powerUpToggle"),
           let background = toggleButton.children.first as? SKSpriteNode {
            background.color = .systemOrange
        }
    }
    
    private func collapsePowerUps() {
        for button in powerUpButtons.values {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let collapse = SKAction.group([fadeOut, scaleDown])
            button.run(collapse)
        }
        
        // Update toggle button
        if let toggleButton = childNode(withName: "powerUpToggle"),
           let background = toggleButton.children.first as? SKSpriteNode {
            background.color = .systemPurple
        }
    }
    
    func showPowerUpActivatedEffect(type: PowerUpType) {
        guard let button = powerUpButtons[type] else { return }
        
        // Create activation effect
        let activationEffect = SKLabelNode(fontNamed: "AvenirNext-Bold")
        activationEffect.text = "ACTIVATED!"
        activationEffect.fontSize = 12
        activationEffect.fontColor = .systemYellow
        activationEffect.position = CGPoint(x: 0, y: 40)
        button.addChild(activationEffect)
        
        let floatUp = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 30, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ]),
            SKAction.removeFromParent()
        ])
        
        activationEffect.run(floatUp)
        
        // Button flash effect
        let flash = SKAction.sequence([
            SKAction.colorize(with: .systemYellow, colorBlendFactor: 0.8, duration: 0.2),
            SKAction.colorize(with: .systemBlue, colorBlendFactor: 0.0, duration: 0.2)
        ])
        
        if let background = button.children.first as? SKSpriteNode {
            background.run(SKAction.repeat(flash, count: 3))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "powerUpToggle" || touchedNode.parent?.name == "powerUpToggle" {
            toggleExpansion()
        } else if let nodeName = touchedNode.name ?? touchedNode.parent?.name,
                  nodeName.hasPrefix("powerUp_") {
            let typeString = String(nodeName.dropFirst(8))
            if let type = PowerUpType(rawValue: typeString) {
                handlePowerUpTap(type)
            }
        }
    }
    
    private func handlePowerUpTap(_ type: PowerUpType) {
        let powerManager = PowerUpManager.shared
        let count = powerManager.getPowerUpCount(type)
        
        if count > 0 {
            if powerManager.activatePowerUp(type) {
                showPowerUpActivatedEffect(type: type)
                updateUI()
                delegate?.powerUpActivated(type)
                
                // Show info popup
                showPowerUpInfo(type)
                
                // Auto-collapse after activation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if self.isExpanded {
                        self.toggleExpansion()
                    }
                }
            }
        } else {
            // Show shop or "need more" message
            showNeedMoreMessage(type)
        }
    }
    
    private func showPowerUpInfo(_ type: PowerUpType) {
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        infoLabel.text = type.description
        infoLabel.fontSize = 14
        infoLabel.fontColor = .systemBlue
        infoLabel.position = CGPoint(x: 0, y: -120)
        infoLabel.alpha = 0
        addChild(infoLabel)
        
        let showInfo = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        
        infoLabel.run(showInfo)
    }
    
    private func showNeedMoreMessage(_ type: PowerUpType) {
        let needMoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        needMoreLabel.text = "Need \(type.gemCost) gems to buy!"
        needMoreLabel.fontSize = 12
        needMoreLabel.fontColor = .systemRed
        needMoreLabel.position = CGPoint(x: 0, y: -120)
        needMoreLabel.alpha = 0
        addChild(needMoreLabel)
        
        let showMessage = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        
        needMoreLabel.run(showMessage)
    }
    
    // Position the power-up UI based on screen size
    func positionForScreen(size: CGSize) {
        position = CGPoint(x: 60, y: size.height - 200)
    }
}