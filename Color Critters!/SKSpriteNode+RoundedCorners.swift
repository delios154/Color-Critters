//
//  SKSpriteNode+RoundedCorners.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

extension SKSpriteNode {
    
    /// Creates a rounded rectangle sprite node with the specified corner radius
    /// - Parameters:
    ///   - color: The color of the sprite
    ///   - size: The size of the sprite
    ///   - cornerRadius: The radius of the corners
    /// - Returns: A sprite node with rounded corners
    static func roundedRect(color: UIColor, size: CGSize, cornerRadius: CGFloat) -> SKSpriteNode {
        // Create a rounded rectangle path
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
        
        // Create a shape node with the path
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = color
        shapeNode.strokeColor = .clear
        
        // Create a sprite node and add the shape as a child
        let sprite = SKSpriteNode(color: .clear, size: size)
        sprite.addChild(shapeNode)
        
        return sprite
    }
    
    /// Adds rounded corners to an existing sprite node
    /// - Parameter cornerRadius: The radius of the corners
    func addRoundedCorners(cornerRadius: CGFloat) {
        // Create a rounded rectangle path
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: self.size), cornerRadius: cornerRadius)
        
        // Create a shape node with the path
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = self.color
        shapeNode.strokeColor = .clear
        
        // Clear the original sprite's color and add the shape
        self.color = .clear
        self.addChild(shapeNode)
    }
} 