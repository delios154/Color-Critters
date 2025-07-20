//
//  SocialSharingManager.swift
//  Color Critters!
//
//  Created for social sharing functionality
//

import UIKit
import SpriteKit

class SocialSharingManager {
    static let shared = SocialSharingManager()
    
    private init() {}
    
    // MARK: - Share Collection Progress
    
    func shareCollectionProgress(from viewController: UIViewController?) {
        let stats = AnimalCollectionManager.shared.getCollectionStats()
        let progressPercentage = Int(stats.completion * 100)
        
        let shareText = """
        I've collected \(stats.unique)/100 animal colors in Color Critters! 🎨
        
        Progress: \(progressPercentage)% complete! 🚀
        
        Can you beat my collection? Download Color Critters now!
        #ColorCritters #AnimalCollection #EducationalGames
        """
        
        presentShareSheet(text: shareText, from: viewController)
    }
    
    // MARK: - Share Achievement
    
    func shareAchievement(_ achievementTitle: String, from viewController: UIViewController?) {
        let shareText = """
        🏆 Achievement Unlocked in Color Critters!
        
        "\(achievementTitle)"
        
        Join me in this fun educational game! 🎨🐾
        #ColorCritters #Achievement #EducationalGames
        """
        
        presentShareSheet(text: shareText, from: viewController)
    }
    
    // MARK: - Share Streak Milestone
    
    func shareStreakMilestone(_ streak: Int, from viewController: UIViewController?) {
        let streakEmoji = getStreakEmoji(streak: streak)
        
        let shareText = """
        \(streakEmoji) \(streak) Color Streak in Color Critters! \(streakEmoji)
        
        I'm on fire with color matching! Can you beat my streak? 🔥
        
        #ColorCritters #Streak #ColorMatching #EducationalGames
        """
        
        presentShareSheet(text: shareText, from: viewController)
    }
    
    // MARK: - Share Colored Animal
    
    func shareColoredAnimal(_ animalName: String, color: UIColor, level: Int, from viewController: UIViewController?) {
        let colorName = AnimalCollectionManager.colorName(for: color)
        
        let shareText = """
        🎨 Just colored a \(colorName.lowercased()) \(animalName) in Color Critters!
        
        Level \(level) complete! 🌟
        
        Help animals find their colors in this fun educational game!
        #ColorCritters #\(animalName.capitalized) #\(colorName) #EducationalGames
        """
        
        presentShareSheet(text: shareText, from: viewController)
    }
    
    // MARK: - Share Game Stats
    
    func shareGameStats(from viewController: UIViewController?) {
        let settings = GameSettings.shared
        let collectionStats = AnimalCollectionManager.shared.getCollectionStats()
        let comboStats = ComboManager.shared.getComboStats()
        
        let shareText = """
        📊 My Color Critters Stats:
        
        🏆 Level: \(settings.playerLevel)
        🎯 Score: \(settings.totalScore)
        🔥 Best Streak: \(settings.bestStreak)
        ⚡ Best Combo: \(comboStats.maxCombo)x
        🎨 Animals Collected: \(collectionStats.unique)/100
        
        Beat my stats in Color Critters! 🚀
        #ColorCritters #GameStats #EducationalGames
        """
        
        presentShareSheet(text: shareText, from: viewController)
    }
    
    // MARK: - Share Mini-Game Score
    
    func shareMiniGameScore(_ score: Int, gameName: String, from viewController: UIViewController?) {
        let shareText = """
        🎮 Mini-Game Challenge Complete!
        
        \(gameName): \(score) points! 🌟
        
        Try the mini-games in Color Critters! 
        #ColorCritters #MiniGame #\(gameName.replacingOccurrences(of: " ", with: ""))
        """
        
        presentShareSheet(text: shareText, from: viewController)
    }
    
    // MARK: - Helper Methods
    
    private func presentShareSheet(text: String, image: UIImage? = nil, from viewController: UIViewController?) {
        guard let viewController = viewController else {
            print("No view controller available for sharing")
            return
        }
        
        var activityItems: [Any] = [text]
        
        if let image = image {
            activityItems.append(image)
        }
        
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Exclude some activities that don't make sense for this content
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        // For iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, 
                                      y: viewController.view.bounds.midY, 
                                      width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    private func getStreakEmoji(streak: Int) -> String {
        switch streak {
        case 1...4: return "⭐"
        case 5...9: return "🔥"
        case 10...19: return "⚡"
        case 20...29: return "🚀"
        case 30...49: return "💫"
        default: return "👑"
        }
    }
    
    // MARK: - Generate Shareable Image
    
    func generateAnimalImage(name: String, color: UIColor, level: Int) -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Background gradient
            let startColor = UIColor.systemBlue.withAlphaComponent(0.3)
            let endColor = UIColor.systemPurple.withAlphaComponent(0.3)
            
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: [startColor.cgColor, endColor.cgColor] as CFArray,
                                       locations: [0.0, 1.0]) {
                context.cgContext.drawLinearGradient(gradient,
                                                   start: CGPoint(x: 0, y: 0),
                                                   end: CGPoint(x: 0, y: size.height),
                                                   options: [])
            }
            
            // Animal image
            let animalSize = CGSize(width: 200, height: 200)
            if let animalImage = AnimalImageGenerator.generateAnimalImage(for: name, size: animalSize),
               let tintedImage = animalImage.tinted(with: color) {
                let animalRect = CGRect(x: (size.width - animalSize.width) / 2,
                                      y: 100,
                                      width: animalSize.width,
                                      height: animalSize.height)
                tintedImage.draw(in: animalRect)
            }
            
            // Text overlay
            let colorName = AnimalCollectionManager.colorName(for: color)
            let text = "\(colorName) \(name.capitalized)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
            ]
            
            let textSize = text.size(withAttributes: textAttributes)
            let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                y: 50,
                                width: textSize.width,
                                height: textSize.height)
            text.draw(in: textRect, withAttributes: textAttributes)
            
            // Level badge
            let levelText = "Level \(level)"
            let levelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -1.0
            ]
            
            let levelSize = levelText.size(withAttributes: levelAttributes)
            let levelRect = CGRect(x: (size.width - levelSize.width) / 2,
                                 y: 320,
                                 width: levelSize.width,
                                 height: levelSize.height)
            levelText.draw(in: levelRect, withAttributes: levelAttributes)
            
            // Color Critters logo text
            let logoText = "Color Critters!"
            let logoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -1.5
            ]
            
            let logoSize = logoText.size(withAttributes: logoAttributes)
            let logoRect = CGRect(x: (size.width - logoSize.width) / 2,
                                y: 350,
                                width: logoSize.width,
                                height: logoSize.height)
            logoText.draw(in: logoRect, withAttributes: logoAttributes)
        }
    }
}

// MARK: - UIImage Extensions

extension UIImage {
    func withBackground(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        draw(at: .zero)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}