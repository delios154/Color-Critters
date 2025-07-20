//
//  AnimalImageGenerator.swift
//  Color Critters!
//
//  Created for animal image generation
//

import UIKit
import SpriteKit

class AnimalImageGenerator {
    
    static func generateAnimalImage(for animal: String, size: CGSize = CGSize(width: 140, height: 140)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let ctx = context.cgContext
            
            // Set up drawing context
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(rect)
            
            // Set animal color (will be tinted later)
            ctx.setFillColor(UIColor.black.cgColor)
            
            // Draw different animal shapes
            switch animal.lowercased() {
            case "frog":
                drawFrog(in: ctx, rect: rect)
            case "cat":
                drawCat(in: ctx, rect: rect)
            case "dog":
                drawDog(in: ctx, rect: rect)
            case "rabbit":
                drawRabbit(in: ctx, rect: rect)
            case "elephant":
                drawElephant(in: ctx, rect: rect)
            case "giraffe":
                drawGiraffe(in: ctx, rect: rect)
            case "lion":
                drawLion(in: ctx, rect: rect)
            case "tiger":
                drawTiger(in: ctx, rect: rect)
            case "bear":
                drawBear(in: ctx, rect: rect)
            case "penguin":
                drawPenguin(in: ctx, rect: rect)
            default:
                // Default animal shape
                let center = CGPoint(x: rect.midX, y: rect.midY)
                let radius = min(rect.width, rect.height) * 0.4
                ctx.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            }
        }
    }
    
    private static func drawFrog(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Body
        let bodyRect = CGRect(x: center.x - size/4, y: center.y - size/6, width: size/2, height: size/3)
        ctx.fillEllipse(in: bodyRect)
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/2, width: size/1.5, height: size/2.5)
        ctx.fillEllipse(in: headRect)
        
        // Eyes
        let eyeSize = size/8
        ctx.fillEllipse(in: CGRect(x: center.x - size/4, y: center.y - size/2.5, width: eyeSize, height: eyeSize))
        ctx.fillEllipse(in: CGRect(x: center.x + size/8, y: center.y - size/2.5, width: eyeSize, height: eyeSize))
        
        // Legs
        let legSize = size/6
        ctx.fillEllipse(in: CGRect(x: center.x - size/2, y: center.y, width: legSize, height: legSize))
        ctx.fillEllipse(in: CGRect(x: center.x + size/3, y: center.y, width: legSize, height: legSize))
    }
    
    private static func drawCat(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Head (circle)
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/3, width: size/1.5, height: size/1.5)
        ctx.fillEllipse(in: headRect)
        
        // Ears (triangles)
        let earHeight = size/4
        let earWidth = size/5
        
        // Left ear
        ctx.move(to: CGPoint(x: center.x - size/4, y: center.y - size/3))
        ctx.addLine(to: CGPoint(x: center.x - size/3, y: center.y - size/2))
        ctx.addLine(to: CGPoint(x: center.x - size/6, y: center.y - size/2))
        ctx.fillPath()
        
        // Right ear
        ctx.move(to: CGPoint(x: center.x + size/4, y: center.y - size/3))
        ctx.addLine(to: CGPoint(x: center.x + size/3, y: center.y - size/2))
        ctx.addLine(to: CGPoint(x: center.x + size/6, y: center.y - size/2))
        ctx.fillPath()
        
        // Body
        let bodyRect = CGRect(x: center.x - size/4, y: center.y + size/6, width: size/2, height: size/2.5)
        ctx.fillEllipse(in: bodyRect)
        
        // Tail
        let tailRect = CGRect(x: center.x + size/4, y: center.y + size/8, width: size/8, height: size/3)
        ctx.fillEllipse(in: tailRect)
    }
    
    private static func drawDog(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/2.5, width: size/1.5, height: size/2)
        ctx.fillEllipse(in: headRect)
        
        // Snout
        let snoutRect = CGRect(x: center.x - size/6, y: center.y - size/4, width: size/3, height: size/6)
        ctx.fillEllipse(in: snoutRect)
        
        // Ears (floppy)
        let earRect1 = CGRect(x: center.x - size/2, y: center.y - size/2, width: size/4, height: size/3)
        let earRect2 = CGRect(x: center.x + size/4, y: center.y - size/2, width: size/4, height: size/3)
        ctx.fillEllipse(in: earRect1)
        ctx.fillEllipse(in: earRect2)
        
        // Body
        let bodyRect = CGRect(x: center.x - size/3, y: center.y, width: size/1.5, height: size/2.5)
        ctx.fillEllipse(in: bodyRect)
        
        // Tail
        let tailRect = CGRect(x: center.x + size/3, y: center.y - size/8, width: size/6, height: size/4)
        ctx.fillEllipse(in: tailRect)
    }
    
    private static func drawRabbit(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/3, width: size/1.5, height: size/1.8)
        ctx.fillEllipse(in: headRect)
        
        // Long ears
        let earRect1 = CGRect(x: center.x - size/3, y: center.y - size/1.5, width: size/6, height: size/2)
        let earRect2 = CGRect(x: center.x + size/6, y: center.y - size/1.5, width: size/6, height: size/2)
        ctx.fillEllipse(in: earRect1)
        ctx.fillEllipse(in: earRect2)
        
        // Body
        let bodyRect = CGRect(x: center.x - size/4, y: center.y + size/8, width: size/2, height: size/2.2)
        ctx.fillEllipse(in: bodyRect)
        
        // Cotton tail
        let tailRect = CGRect(x: center.x + size/4, y: center.y + size/4, width: size/8, height: size/8)
        ctx.fillEllipse(in: tailRect)
    }
    
    private static func drawElephant(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Body (large)
        let bodyRect = CGRect(x: center.x - size/2.5, y: center.y - size/6, width: size/1.2, height: size/1.8)
        ctx.fillEllipse(in: bodyRect)
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/2, width: size/1.5, height: size/2.2)
        ctx.fillEllipse(in: headRect)
        
        // Trunk
        let trunkRect = CGRect(x: center.x - size/8, y: center.y - size/8, width: size/4, height: size/1.5)
        ctx.fillEllipse(in: trunkRect)
        
        // Ears (large)
        let earRect1 = CGRect(x: center.x - size/2, y: center.y - size/2.5, width: size/3, height: size/2.5)
        let earRect2 = CGRect(x: center.x + size/6, y: center.y - size/2.5, width: size/3, height: size/2.5)
        ctx.fillEllipse(in: earRect1)
        ctx.fillEllipse(in: earRect2)
    }
    
    private static func drawGiraffe(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Body
        let bodyRect = CGRect(x: center.x - size/4, y: center.y, width: size/2, height: size/2.5)
        ctx.fillEllipse(in: bodyRect)
        
        // Long neck
        let neckRect = CGRect(x: center.x - size/8, y: center.y - size/1.2, width: size/4, height: size/1.2)
        ctx.fill(neckRect)
        
        // Head
        let headRect = CGRect(x: center.x - size/6, y: center.y - size/1.5, width: size/3, height: size/4)
        ctx.fillEllipse(in: headRect)
        
        // Horns
        let hornRect1 = CGRect(x: center.x - size/12, y: center.y - size/1.3, width: size/20, height: size/10)
        let hornRect2 = CGRect(x: center.x + size/20, y: center.y - size/1.3, width: size/20, height: size/10)
        ctx.fill(hornRect1)
        ctx.fill(hornRect2)
        
        // Legs
        let legWidth = size/12
        let legHeight = size/4
        ctx.fill(CGRect(x: center.x - size/5, y: center.y + size/2.5, width: legWidth, height: legHeight))
        ctx.fill(CGRect(x: center.x + size/8, y: center.y + size/2.5, width: legWidth, height: legHeight))
    }
    
    private static func drawLion(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Mane
        let maneRect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size/1.2)
        ctx.fillEllipse(in: maneRect)
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/3, width: size/1.5, height: size/1.5)
        ctx.setFillColor(UIColor.darkGray.cgColor)
        ctx.fillEllipse(in: headRect)
        ctx.setFillColor(UIColor.black.cgColor)
        
        // Body
        let bodyRect = CGRect(x: center.x - size/4, y: center.y + size/6, width: size/2, height: size/2.5)
        ctx.fillEllipse(in: bodyRect)
        
        // Tail with tuft
        let tailRect = CGRect(x: center.x + size/4, y: center.y + size/8, width: size/8, height: size/3)
        ctx.fillEllipse(in: tailRect)
        let tuftRect = CGRect(x: center.x + size/3, y: center.y + size/2.5, width: size/6, height: size/6)
        ctx.fillEllipse(in: tuftRect)
    }
    
    private static func drawTiger(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/2.5, width: size/1.5, height: size/2)
        ctx.fillEllipse(in: headRect)
        
        // Ears
        let earRect1 = CGRect(x: center.x - size/3, y: center.y - size/2.5, width: size/6, height: size/6)
        let earRect2 = CGRect(x: center.x + size/6, y: center.y - size/2.5, width: size/6, height: size/6)
        ctx.fillEllipse(in: earRect1)
        ctx.fillEllipse(in: earRect2)
        
        // Body
        let bodyRect = CGRect(x: center.x - size/3, y: center.y - size/6, width: size/1.5, height: size/1.5)
        ctx.fillEllipse(in: bodyRect)
        
        // Stripes (simple rectangles)
        ctx.setFillColor(UIColor.darkGray.cgColor)
        for i in 0..<4 {
            let stripeY = center.y - size/6 + CGFloat(i) * size/8
            let stripeRect = CGRect(x: center.x - size/4, y: stripeY, width: size/2, height: size/20)
            ctx.fill(stripeRect)
        }
        ctx.setFillColor(UIColor.black.cgColor)
        
        // Tail
        let tailRect = CGRect(x: center.x + size/3, y: center.y, width: size/6, height: size/4)
        ctx.fillEllipse(in: tailRect)
    }
    
    private static func drawBear(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Body (large and round)
        let bodyRect = CGRect(x: center.x - size/2.5, y: center.y - size/4, width: size/1.2, height: size/1.2)
        ctx.fillEllipse(in: bodyRect)
        
        // Head
        let headRect = CGRect(x: center.x - size/3, y: center.y - size/1.8, width: size/1.5, height: size/1.8)
        ctx.fillEllipse(in: headRect)
        
        // Small round ears
        let earRect1 = CGRect(x: center.x - size/4, y: center.y - size/1.5, width: size/8, height: size/8)
        let earRect2 = CGRect(x: center.x + size/8, y: center.y - size/1.5, width: size/8, height: size/8)
        ctx.fillEllipse(in: earRect1)
        ctx.fillEllipse(in: earRect2)
        
        // Snout
        let snoutRect = CGRect(x: center.x - size/8, y: center.y - size/3, width: size/4, height: size/6)
        ctx.fillEllipse(in: snoutRect)
    }
    
    private static func drawPenguin(in ctx: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Body (oval, upright)
        let bodyRect = CGRect(x: center.x - size/3, y: center.y - size/3, width: size/1.5, height: size/1.2)
        ctx.fillEllipse(in: bodyRect)
        
        // White belly
        ctx.setFillColor(UIColor.lightGray.cgColor)
        let bellyRect = CGRect(x: center.x - size/5, y: center.y - size/4, width: size/2.5, height: size/1.5)
        ctx.fillEllipse(in: bellyRect)
        ctx.setFillColor(UIColor.black.cgColor)
        
        // Head
        let headRect = CGRect(x: center.x - size/4, y: center.y - size/1.5, width: size/2, height: size/2.5)
        ctx.fillEllipse(in: headRect)
        
        // Beak
        ctx.setFillColor(UIColor.orange.cgColor)
        let beakRect = CGRect(x: center.x - size/12, y: center.y - size/1.8, width: size/6, height: size/12)
        ctx.fillEllipse(in: beakRect)
        ctx.setFillColor(UIColor.black.cgColor)
        
        // Flippers
        let flipperRect1 = CGRect(x: center.x - size/2, y: center.y - size/6, width: size/6, height: size/3)
        let flipperRect2 = CGRect(x: center.x + size/3, y: center.y - size/6, width: size/6, height: size/3)
        ctx.fillEllipse(in: flipperRect1)
        ctx.fillEllipse(in: flipperRect2)
        
        // Feet
        ctx.setFillColor(UIColor.orange.cgColor)
        let feetRect1 = CGRect(x: center.x - size/6, y: center.y + size/2.5, width: size/8, height: size/12)
        let feetRect2 = CGRect(x: center.x + size/12, y: center.y + size/2.5, width: size/8, height: size/12)
        ctx.fillEllipse(in: feetRect1)
        ctx.fillEllipse(in: feetRect2)
    }
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
} 