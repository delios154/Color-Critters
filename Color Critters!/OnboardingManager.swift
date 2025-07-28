//
//  OnboardingManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

enum OnboardingStep: Int {
    case welcome = 0
    case meetCritter
    case introduceColors
    case tryDragging
    case success
    case features
    case complete
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Color Critters!"
        case .meetCritter:
            return "Meet Your First Friend"
        case .introduceColors:
            return "Color Magic"
        case .tryDragging:
            return "Let's Try It!"
        case .success:
            return "Amazing!"
        case .features:
            return "Special Features"
        case .complete:
            return "You're Ready!"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Help adorable animals get their colors back in this fun learning game!"
        case .meetCritter:
            return "This little frog has lost its color. Can you help?"
        case .introduceColors:
            return "These are color blobs. Each one has a special color!"
        case .tryDragging:
            return "Drag the green color blob to the frog"
        case .success:
            return "You did it! The frog is happy and green again!"
        case .features:
            return "Earn coins, unlock new animals, and track your progress!"
        case .complete:
            return "Let's start your colorful adventure!"
        }
    }
}

class OnboardingManager: SKNode {
    
    // MARK: - Properties
    private var currentStep: OnboardingStep = .welcome
    private var overlayBackground: SKSpriteNode!
    private var contentContainer: SKNode!
    private var titleLabel: SKLabelNode!
    private var descriptionLabel: SKLabelNode!
    private var mascotSprite: SKSpriteNode!
    private var nextButton: SKSpriteNode!
    private var skipButton: SKSpriteNode!
    private var progressDots: [SKShapeNode] = []
    private var spotlightNode: SKNode?
    private var arrowIndicator: SKSpriteNode?
    
    private weak var gameScene: SKScene?
    private var completion: (() -> Void)?
    
    // MARK: - Initialization
    
    init(in scene: SKScene, completion: @escaping () -> Void) {
        super.init()
        self.gameScene = scene
        self.completion = completion
        self.zPosition = 1000
        setupOnboarding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupOnboarding() {
        guard let scene = gameScene else { return }
        
        // Semi-transparent background
        overlayBackground = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: scene.size)
        overlayBackground.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        addChild(overlayBackground)
        
        // Content container
        contentContainer = SKNode()
        contentContainer.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        addChild(contentContainer)
        
        // Create mascot character
        createMascot()
        
        // Create text elements
        createTextElements()
        
        // Create navigation
        createNavigation()
        
        // Create progress indicator
        createProgressIndicator()
        
        // Show first step
        showCurrentStep()
    }
    
    private func createMascot() {
        // Create a friendly guide character
        mascotSprite = SKSpriteNode(color: .systemPurple, size: CGSize(width: 80, height: 80))
        mascotSprite.position = CGPoint(x: 0, y: 100)
        
        // Add eyes
        let leftEye = SKShapeNode(circleOfRadius: 8)
        leftEye.fillColor = .white
        leftEye.position = CGPoint(x: -15, y: 10)
        mascotSprite.addChild(leftEye)
        
        let leftPupil = SKShapeNode(circleOfRadius: 4)
        leftPupil.fillColor = .black
        leftPupil.position = CGPoint(x: -15, y: 10)
        mascotSprite.addChild(leftPupil)
        
        let rightEye = SKShapeNode(circleOfRadius: 8)
        rightEye.fillColor = .white
        rightEye.position = CGPoint(x: 15, y: 10)
        mascotSprite.addChild(rightEye)
        
        let rightPupil = SKShapeNode(circleOfRadius: 4)
        rightPupil.fillColor = .black
        rightPupil.position = CGPoint(x: 15, y: 10)
        mascotSprite.addChild(rightPupil)
        
        // Add smile
        let smile = SKShapeNode()
        let smilePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: -5),
                                     radius: 20,
                                     startAngle: CGFloat.pi * 1.2,
                                     endAngle: CGFloat.pi * 1.8,
                                     clockwise: false)
        smile.path = smilePath.cgPath
        smile.strokeColor = .white
        smile.lineWidth = 3
        mascotSprite.addChild(smile)
        
        contentContainer.addChild(mascotSprite)
        
        // Add bouncing animation
        let bounce = AnimationManager.shared.floatingAnimation(amplitude: 20, duration: 2.0)
        mascotSprite.run(bounce)
    }
    
    private func createTextElements() {
        guard let scene = gameScene else { return }
        
        // Title label
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.fontSize = AccessibilityManager.shared.getAccessibleFontSize(baseSize: 32)
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 20)
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = scene.size.width * 0.8
        contentContainer.addChild(titleLabel)
        
        // Description label
        descriptionLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        descriptionLabel.fontSize = AccessibilityManager.shared.getAccessibleFontSize(baseSize: 20)
        descriptionLabel.fontColor = .white
        descriptionLabel.position = CGPoint(x: 0, y: -40)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.preferredMaxLayoutWidth = scene.size.width * 0.8
        descriptionLabel.verticalAlignmentMode = .center
        contentContainer.addChild(descriptionLabel)
    }
    
    private func createNavigation() {
        guard let scene = gameScene else { return }
        
        // Next button
        nextButton = createButton(text: "Next", color: .systemGreen)
        nextButton.position = CGPoint(x: 100, y: -scene.size.height/2 + 100)
        nextButton.name = "nextButton"
        addChild(nextButton)
        
        // Skip button
        skipButton = createButton(text: "Skip", color: .systemGray)
        skipButton.position = CGPoint(x: -100, y: -scene.size.height/2 + 100)
        skipButton.name = "skipButton"
        addChild(skipButton)
    }
    
    private func createButton(text: String, color: UIColor) -> SKSpriteNode {
        let button = SKSpriteNode(color: color, size: CGSize(width: 120, height: 50))
        button.name = text.lowercased() + "Button"
        
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        // Add rounded corners effect
        let cornerRadius: CGFloat = 25
        let roundedRect = UIBezierPath(roundedRect: CGRect(x: -60, y: -25, width: 120, height: 50), cornerRadius: cornerRadius)
        let shape = SKShapeNode(path: roundedRect.cgPath)
        shape.fillColor = color
        shape.strokeColor = .clear
        button.texture = nil
        button.color = .clear
        button.addChild(shape)
        shape.zPosition = -1
        
        AccessibilityManager.shared.configureButtonAccessibility(button, label: text, action: text.lowercased())
        
        return button
    }
    
    private func createProgressIndicator() {
        guard let scene = gameScene else { return }
        
        let totalSteps = 7
        let dotSpacing: CGFloat = 30
        let startX = -(CGFloat(totalSteps - 1) * dotSpacing) / 2
        
        for i in 0..<totalSteps {
            let dot = SKShapeNode(circleOfRadius: 5)
            dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -scene.size.height/2 + 50)
            dot.fillColor = i == 0 ? .white : .gray
            addChild(dot)
            progressDots.append(dot)
        }
    }
    
    // MARK: - Step Management
    
    private func showCurrentStep() {
        // Update text
        titleLabel.text = currentStep.title
        descriptionLabel.text = currentStep.description
        
        // Update progress dots
        for (index, dot) in progressDots.enumerated() {
            dot.fillColor = index <= currentStep.rawValue ? .white : .gray
        }
        
        // Show step-specific content
        switch currentStep {
        case .welcome:
            showWelcome()
        case .meetCritter:
            showMeetCritter()
        case .introduceColors:
            showIntroduceColors()
        case .tryDragging:
            showTryDragging()
        case .success:
            showSuccess()
        case .features:
            showFeatures()
        case .complete:
            showComplete()
        }
        
        // Animate content appearance
        contentContainer.alpha = 0
        contentContainer.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    private func showWelcome() {
        mascotSprite.run(AnimationManager.shared.pulseAnimation())
    }
    
    private func showMeetCritter() {
        createSpotlight(at: CGPoint(x: 0, y: 0), radius: 150)
    }
    
    private func showIntroduceColors() {
        if let scene = gameScene {
            let positions = [
                CGPoint(x: -100, y: -100),
                CGPoint(x: 0, y: -100),
                CGPoint(x: 100, y: -100)
            ]
            
            for (index, position) in positions.enumerated() {
                createSpotlight(at: position, radius: 60)
                
                // Add sample color blobs
                let colorBlob = SKSpriteNode(color: [UIColor.red, UIColor.green, UIColor.blue][index], size: CGSize(width: 50, height: 50))
                colorBlob.position = position
                colorBlob.zPosition = 1001
                colorBlob.alpha = 0
                addChild(colorBlob)
                
                let delay = SKAction.wait(forDuration: Double(index) * 0.2)
                let fadeIn = SKAction.fadeIn(withDuration: 0.3)
                let pulse = AnimationManager.shared.pulseAnimation()
                colorBlob.run(SKAction.sequence([delay, fadeIn, pulse]))
            }
        }
    }
    
    private func showTryDragging() {
        createArrowIndicator()
    }
    
    private func showSuccess() {
        if let scene = self.scene {
            AnimationManager.shared.celebrateSuccess(at: CGPoint.zero, in: scene)
        }
    }
    
    private func showFeatures() {
        // Show feature icons
        let features = ["🏆", "🎁", "📊"]
        let positions = [CGPoint(x: -80, y: -100), CGPoint(x: 0, y: -100), CGPoint(x: 80, y: -100)]
        
        for (index, (icon, position)) in zip(features, positions).enumerated() {
            let featureNode = SKLabelNode(text: icon)
            featureNode.fontSize = 40
            featureNode.position = position
            featureNode.alpha = 0
            contentContainer.addChild(featureNode)
            
            let delay = SKAction.wait(forDuration: Double(index) * 0.2)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let bounce = AnimationManager.shared.bounceAnimation()
            featureNode.run(SKAction.sequence([delay, fadeIn, bounce]))
        }
    }
    
    private func showComplete() {
        nextButton.removeAllChildren()
        let label = SKLabelNode(text: "Start Playing!")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        nextButton.addChild(label)
        
        nextButton.run(AnimationManager.shared.pulseAnimation(scale: 1.1, duration: 1.0))
    }
    
    // MARK: - Visual Effects
    
    private func createSpotlight(at position: CGPoint, radius: CGFloat) {
        spotlightNode?.removeFromParent()
        
        guard let scene = gameScene else { return }
        
        // Create a dark overlay with a transparent circle for spotlight effect
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.3), size: scene.size)
        overlay.zPosition = 999
        overlay.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        
        // Create a mask node with a circle
        let maskNode = SKShapeNode(circleOfRadius: radius)
        maskNode.fillColor = .white
        maskNode.strokeColor = .clear
        maskNode.position = position
        
        // Create crop node for the spotlight effect
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.zPosition = 1000
        
        // Add a clear node to the crop node (this creates the hole)
        let clearNode = SKSpriteNode(color: .clear, size: scene.size)
        clearNode.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        cropNode.addChild(clearNode)
        
        spotlightNode = overlay
        insertChild(overlay, at: 1)
        
        // Animate spotlight
        overlay.alpha = 0
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    private func createArrowIndicator() {
        arrowIndicator?.removeFromParent()
        
        let arrow = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 40))
        arrow.position = CGPoint(x: -50, y: -150)
        arrow.zPosition = 1002
        
        // Create arrow shape
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 20))
        arrowPath.addLine(to: CGPoint(x: 20, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: -20))
        arrowPath.addLine(to: CGPoint(x: -10, y: -20))
        arrowPath.addLine(to: CGPoint(x: -10, y: 0))
        arrowPath.addLine(to: CGPoint(x: -20, y: 0))
        arrowPath.close()
        
        let arrowShape = SKShapeNode(path: arrowPath.cgPath)
        arrowShape.fillColor = .white
        arrow.addChild(arrowShape)
        
        arrowIndicator = arrow
        addChild(arrow)
        
        // Animate arrow
        let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 1.0)
        let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 0.3)
        let sequence = SKAction.sequence([moveRight, moveLeft])
        arrow.run(SKAction.repeatForever(sequence))
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "nextButton" {
                handleNext()
            } else if node.name == "skipButton" {
                handleSkip()
            }
        }
    }
    
    private func handleNext() {
        HapticManager.shared.buttonTap()
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
            showCurrentStep()
        } else {
            completeOnboarding()
        }
    }
    
    private func handleSkip() {
        HapticManager.shared.buttonTap()
        
        let alert = SKNode()
        // In a real implementation, you'd show a confirmation dialog
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        GameSettings.shared.hasCompletedOnboarding = true
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let complete = SKAction.run { [weak self] in
            self?.completion?()
        }
        
        run(SKAction.sequence([fadeOut, remove, complete]))
    }
}