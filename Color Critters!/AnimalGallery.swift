//
//  AnimalGallery.swift
//  Color Critters!
//
//  Created for displaying collected animals
//

import SpriteKit

protocol AnimalGalleryDelegate: AnyObject {
    func galleryDidClose()
}

class AnimalGallery: SKNode {
    weak var delegate: AnimalGalleryDelegate?
    var isActive = false
    
    private var scrollView: SKNode!
    private var contentNode: SKNode!
    private var scrollOffset: CGFloat = 0
    private let itemsPerRow = 4
    private let itemSize = CGSize(width: 80, height: 80)
    private let itemSpacing: CGFloat = 20
    
    override init() {
        super.init()
        setupGallery()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGallery() {
        // Background overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.8), 
                                  size: CGSize(width: 2000, height: 2000))
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = -1
        addChild(overlay)
        
        // Main container
        let containerSize = CGSize(width: 400, height: 500)
        let container = SKSpriteNode.roundedRect(color: .white, size: containerSize, cornerRadius: 25)
        container.position = CGPoint(x: 0, y: 0)
        addChild(container)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Animal Collection"
        title.fontSize = 24
        title.fontColor = .darkGray
        title.position = CGPoint(x: 0, y: containerSize.height/2 - 40)
        container.addChild(title)
        
        // Collection stats
        let stats = AnimalCollectionManager.shared.getCollectionStats()
        let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        statsLabel.text = "\(stats.unique)/100 Animals • \(Int(stats.completion * 100))% Complete"
        statsLabel.fontSize = 16
        statsLabel.fontColor = .systemBlue
        statsLabel.position = CGPoint(x: 0, y: containerSize.height/2 - 70)
        container.addChild(statsLabel)
        
        // Progress bar
        let progressBarWidth: CGFloat = 300
        let progressBarHeight: CGFloat = 8
        let progressBackground = SKSpriteNode.roundedRect(color: .lightGray, 
                                                         size: CGSize(width: progressBarWidth, height: progressBarHeight), 
                                                         cornerRadius: 4)
        progressBackground.position = CGPoint(x: 0, y: containerSize.height/2 - 100)
        container.addChild(progressBackground)
        
        let progressFill = SKSpriteNode.roundedRect(color: .systemGreen, 
                                                   size: CGSize(width: progressBarWidth * stats.completion, height: progressBarHeight), 
                                                   cornerRadius: 4)
        progressFill.position = CGPoint(x: -progressBarWidth/2 + (progressBarWidth * stats.completion)/2, y: 0)
        progressBackground.addChild(progressFill)
        
        // Scroll area
        let scrollAreaSize = CGSize(width: containerSize.width - 40, height: 300)
        scrollView = SKNode()
        scrollView.position = CGPoint(x: 0, y: -50)
        container.addChild(scrollView)
        
        // Content node for scrolling
        contentNode = SKNode()
        scrollView.addChild(contentNode)
        
        // Populate with collected animals
        populateGallery()
        
        // Close button
        let closeButton = SKSpriteNode.roundedRect(color: .systemRed, size: CGSize(width: 100, height: 40), cornerRadius: 20)
        closeButton.position = CGPoint(x: 0, y: -containerSize.height/2 + 30)
        closeButton.name = "closeGallery"
        container.addChild(closeButton)
        
        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.text = "Close"
        closeLabel.fontSize = 18
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
    }
    
    private func populateGallery() {
        let collection = AnimalCollectionManager.shared.getCollection()
        let allAnimals = ["frog", "cat", "dog", "rabbit", "elephant", "giraffe", "lion", "tiger", "bear", "penguin"]
        let allColors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple, .systemPink, .brown, .cyan, .magenta]
        
        var yPosition: CGFloat = 100
        let startX: CGFloat = -150
        
        // Group by animal type
        for (animalIndex, animal) in allAnimals.enumerated() {
            // Animal name header
            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nameLabel.text = animal.capitalized
            nameLabel.fontSize = 16
            nameLabel.fontColor = .darkGray
            nameLabel.position = CGPoint(x: startX, y: yPosition)
            nameLabel.horizontalAlignmentMode = .left
            contentNode.addChild(nameLabel)
            
            yPosition -= 30
            
            // Show collected colors for this animal
            var xPosition = startX
            let animalsOfThisType = collection.filter { $0.name == animal }
            let collectedColors = Set(animalsOfThisType.map { $0.colorName })
            
            for (colorIndex, color) in allColors.enumerated() {
                let colorName = AnimalCollectionManager.colorName(for: color)
                let isCollected = collectedColors.contains(colorName)
                
                // Create slot
                let slotSize = CGSize(width: 60, height: 60)
                let slot = SKSpriteNode.roundedRect(color: isCollected ? .white : .lightGray, 
                                                   size: slotSize, cornerRadius: 8)
                slot.position = CGPoint(x: xPosition, y: yPosition)
                contentNode.addChild(slot)
                
                if isCollected {
                    // Show animal image
                    if let animalImage = AnimalImageGenerator.generateAnimalImage(for: animal, size: CGSize(width: 50, height: 50)),
                       let tintedImage = animalImage.tinted(with: color) {
                        let texture = SKTexture(image: tintedImage)
                        let sprite = SKSpriteNode(texture: texture)
                        sprite.size = CGSize(width: 45, height: 45)
                        slot.addChild(sprite)
                    } else {
                        // Fallback to colored circle
                        let circle = SKSpriteNode.roundedRect(color: color, size: CGSize(width: 45, height: 45), cornerRadius: 22.5)
                        slot.addChild(circle)
                    }
                    
                    // Add glow effect
                    slot.run(SKAction.repeatForever(SKAction.sequence([
                        SKAction.run {
                            slot.color = .systemYellow
                            slot.colorBlendFactor = 0.2
                        },
                        SKAction.wait(forDuration: 1.0),
                        SKAction.run {
                            slot.color = .white
                            slot.colorBlendFactor = 0.0
                        },
                        SKAction.wait(forDuration: 1.0)
                    ])))
                } else {
                    // Show locked slot with question mark
                    let questionMark = SKLabelNode(fontNamed: "AvenirNext-Bold")
                    questionMark.text = "?"
                    questionMark.fontSize = 24
                    questionMark.fontColor = .darkGray
                    questionMark.verticalAlignmentMode = .center
                    slot.addChild(questionMark)
                }
                
                xPosition += 70
                
                // Move to next row after 4 items
                if (colorIndex + 1) % itemsPerRow == 0 {
                    xPosition = startX
                    yPosition -= 80
                }
            }
            
            // Move to next animal section
            if allColors.count % itemsPerRow != 0 {
                yPosition -= 80 // Add extra space if we didn't complete a full row
            }
            yPosition -= 20 // Space between animals
        }
    }
    
    func showGallery() {
        isActive = true
        alpha = 0
        setScale(0.8)
        
        run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
    }
    
    func handleTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "closeGallery" || touchedNode.parent?.name == "closeGallery" {
            closeGallery()
        }
    }
    
    private func closeGallery() {
        isActive = false
        
        run(SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.scale(to: 0.8, duration: 0.3)
        ])) {
            self.delegate?.galleryDidClose()
        }
    }
}

