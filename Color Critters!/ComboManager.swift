//
//  ComboManager.swift
//  Color Critters!
//
//  Created for managing combo chains and multipliers
//

import Foundation
import SpriteKit

enum ComboEffectIntensity {
    case low
    case medium
    case high
    case extreme
    
    var screenShakeIntensity: CGFloat {
        switch self {
        case .low: return 2.0
        case .medium: return 5.0
        case .high: return 10.0
        case .extreme: return 15.0
        }
    }
}

class ComboManager {
    static let shared = ComboManager()
    
    private var currentCombo: Int = 0
    private var maxCombo: Int = 0
    private var comboStartTime: Date?
    private let comboTimeLimit: TimeInterval = 3.0 // 3 seconds to maintain combo
    
    private init() {
        loadComboData()
    }
    
    // MARK: - Combo Management
    
    func addCorrectAnswer() {
        let now = Date()
        
        // Check if combo chain is still valid (within time limit)
        if let startTime = comboStartTime {
            let timeSinceStart = now.timeIntervalSince(startTime)
            if timeSinceStart > comboTimeLimit {
                resetCombo()
            }
        }
        
        currentCombo += 1
        comboStartTime = now
        
        if currentCombo > maxCombo {
            maxCombo = currentCombo
            saveComboData()
        }
    }
    
    func breakCombo() {
        currentCombo = 0
        comboStartTime = nil
    }
    
    func resetCombo() {
        currentCombo = 0
        comboStartTime = nil
    }
    
    // MARK: - Combo Properties
    
    var combo: Int {
        return currentCombo
    }
    
    var bestCombo: Int {
        return maxCombo
    }
    
    var isActive: Bool {
        return currentCombo > 1
    }
    
    // MARK: - Combo Multipliers
    
    func getScoreMultiplier() -> Double {
        switch currentCombo {
        case 0...1: return 1.0
        case 2...4: return 1.2
        case 5...9: return 1.5
        case 10...19: return 2.0
        case 20...49: return 2.5
        default: return 3.0
        }
    }
    
    func getCoinMultiplier() -> Double {
        switch currentCombo {
        case 0...2: return 1.0
        case 3...5: return 1.1
        case 6...10: return 1.3
        case 11...20: return 1.5
        default: return 2.0
        }
    }
    
    func getXPMultiplier() -> Double {
        switch currentCombo {
        case 0...3: return 1.0
        case 4...7: return 1.2
        case 8...15: return 1.4
        default: return 1.8
        }
    }
    
    // MARK: - Combo Messages
    
    func getComboMessage() -> String? {
        switch currentCombo {
        case 3: return "COMBO x3! 🔥"
        case 5: return "GREAT COMBO! ⚡"
        case 10: return "AMAZING COMBO! 🚀"
        case 15: return "INCREDIBLE! 💫"
        case 20: return "UNSTOPPABLE! 🏆"
        case 25: return "LEGENDARY COMBO! 👑"
        default:
            if currentCombo >= 30 && currentCombo % 5 == 0 {
                return "GODLIKE! \(currentCombo)x 🌟"
            }
            return nil
        }
    }
    
    func getComboColor() -> UIColor {
        switch currentCombo {
        case 0...2: return .systemGray
        case 3...5: return .systemOrange
        case 6...10: return .systemRed
        case 11...20: return .systemPurple
        default: return .systemYellow
        }
    }
    
    // MARK: - Visual Effects
    
    func shouldShowComboEffect() -> Bool {
        return currentCombo >= 3 && (currentCombo == 3 || currentCombo % 5 == 0)
    }
    
    func getComboEffectIntensity() -> ComboEffectIntensity {
        switch currentCombo {
        case 0...5: return .low
        case 6...15: return .medium
        case 16...25: return .high
        default: return .extreme
        }
    }
    
    // MARK: - Time Management
    
    func getTimeRemaining() -> TimeInterval? {
        guard let startTime = comboStartTime else { return nil }
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, comboTimeLimit - elapsed)
    }
    
    func isComboExpiring() -> Bool {
        guard let remaining = getTimeRemaining() else { return false }
        return remaining <= 1.0 // Less than 1 second remaining
    }
    
    // MARK: - Persistence
    
    private func loadComboData() {
        maxCombo = UserDefaults.standard.integer(forKey: "MaxCombo")
    }
    
    private func saveComboData() {
        UserDefaults.standard.set(maxCombo, forKey: "MaxCombo")
    }
    
    // MARK: - Statistics
    
    func getComboStats() -> ComboStats {
        return ComboStats(
            currentCombo: currentCombo,
            maxCombo: maxCombo,
            scoreMultiplier: getScoreMultiplier(),
            coinMultiplier: getCoinMultiplier(),
            xpMultiplier: getXPMultiplier(),
            timeRemaining: getTimeRemaining()
        )
    }
}

// MARK: - Data Structures

struct ComboStats {
    let currentCombo: Int
    let maxCombo: Int
    let scoreMultiplier: Double
    let coinMultiplier: Double
    let xpMultiplier: Double
    let timeRemaining: TimeInterval?
}

enum ComboEffectIntensity {
    case low
    case medium
    case high
    case extreme
    
    var particleCount: Int {
        switch self {
        case .low: return 20
        case .medium: return 40
        case .high: return 60
        case .extreme: return 100
        }
    }
    
    var screenShakeIntensity: CGFloat {
        switch self {
        case .low: return 2.0
        case .medium: return 4.0
        case .high: return 6.0
        case .extreme: return 8.0
        }
    }
}