//
//  TutorialOverlay.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

protocol TutorialOverlayDelegate: AnyObject {
    func tutorialDidComplete()
}

class TutorialOverlay: SKNode {
    
    private var tutorialSteps: [TutorialStep] = []
    private var currentStepIndex = 0
    var isActive = false
    
    weak var delegate: TutorialOverlayDelegate?
    
    struct TutorialStep {
        let message: String
        let highlightNode: SKNode?
        let position: CGPoint?
        let action: (() -> Void)?
    }
    
    override init() {
        super.init()
        setupTutorialSteps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTutorialSteps()
    }
    
    private func setupTutorialSteps() {
        tutorialSteps = [
            TutorialStep(
                message: "Welcome to Color Critters! 🎨\nDrag the magenta blob to the bear!",
                highlightNode: nil,
                position: nil,
                action: nil
            )
        ]
    }
    
    func startTutorial() {
        guard !isActive else { return }
        
        isActive = true
        currentStepIndex = 0
        
        showCurrentStep()
    }
    
    private func showCurrentStep() {
        guard currentStepIndex < tutorialSteps.count else {
            completeTutorial()
            return
        }
        
        let step = tutorialSteps[currentStepIndex]
        
        // Clear previous step
        removeAllChildren()
        
        // Create a very small, non-blocking overlay at the very top
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.2), size: CGSize(width: 300, height: 80))
        overlay.position = CGPoint(x: (self.scene?.size.width ?? 0) / 2, y: (self.scene?.size.height ?? 0) - 50)
        overlay.name = "tutorialOverlay"
        addChild(overlay)
        
        // Create message container
        let messageContainer = SKSpriteNode.roundedRect(color: .white, size: CGSize(width: 290, height: 70), cornerRadius: 15)
        messageContainer.position = CGPoint(x: 0, y: 0)
        messageContainer.name = "messageContainer"
        overlay.addChild(messageContainer)
        
        // Create message label
        let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        messageLabel.text = step.message
        messageLabel.fontSize = 14
        messageLabel.fontColor = .darkGray
        messageLabel.numberOfLines = 0
        messageLabel.preferredMaxLayoutWidth = 270
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageContainer.addChild(messageLabel)
        
        // Create continue button
        let continueButton = SKSpriteNode.roundedRect(color: .systemBlue, size: CGSize(width: 80, height: 30), cornerRadius: 15)
        continueButton.position = CGPoint(x: 0, y: -50)
        continueButton.name = "continueButton"
        
        let buttonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        buttonLabel.text = "Got it!"
        buttonLabel.fontSize = 12
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        continueButton.addChild(buttonLabel)
        
        messageContainer.addChild(continueButton)
        
        // Add highlight if needed
        if let highlightNode = step.highlightNode {
            addHighlight(to: highlightNode)
        }
        
        // Execute action if needed
        step.action?()
    }
    
    private func addHighlight(to node: SKNode) {
        let highlight = SKSpriteNode(color: .clear, size: node.frame.size)
        highlight.position = node.position
        highlight.zPosition = node.zPosition + 1
        
        // Create pulsing animation
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        highlight.run(SKAction.repeatForever(pulseAction))
        
        // Add border
        let border = SKShapeNode(rect: highlight.frame)
        border.strokeColor = .systemYellow
        border.lineWidth = 3
        border.zPosition = highlight.zPosition + 1
        highlight.addChild(border)
        
        addChild(highlight)
    }
    
    private func nextStep() {
        currentStepIndex += 1
        showCurrentStep()
    }
    
    private func completeTutorial() {
        isActive = false
        removeFromParent()
        delegate?.tutorialDidComplete()
    }
    
    // MARK: - Touch Handling
    func handleTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "continueButton" {
            SoundManager.shared.playTapSound()
            nextStep()
        }
    }
} 