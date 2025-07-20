//
//  PowerUpManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import Foundation
import SpriteKit

enum PowerUpType: String, CaseIterable {
    case colorHint = "color_hint"
    case scoreBoost = "score_boost"
    case streakProtect = "streak_protect"
    case doubleCoins = "double_coins"
    case timeFreeze = "time_freeze"
    
    var name: String {
        switch self {
        case .colorHint: return "Color Hint"
        case .scoreBoost: return "Score Boost"
        case .streakProtect: return "Streak Shield"
        case .doubleCoins: return "Double Coins"
        case .timeFreeze: return "Time Freeze"
        }
    }
    
    var description: String {
        switch self {
        case .colorHint: return "Shows the correct color briefly"
        case .scoreBoost: return "2x points for next match"
        case .streakProtect: return "Protects streak from one mistake"
        case .doubleCoins: return "2x coins for 5 matches"
        case .timeFreeze: return "Adds extra time to think"
        }
    }
    
    var icon: String {
        switch self {
        case .colorHint: return "💡"
        case .scoreBoost: return "⚡"
        case .streakProtect: return "🛡️"
        case .doubleCoins: return "💰"
        case .timeFreeze: return "❄️"
        }
    }
    
    var gemCost: Int {
        switch self {
        case .colorHint: return 3
        case .scoreBoost: return 5
        case .streakProtect: return 8
        case .doubleCoins: return 6
        case .timeFreeze: return 4
        }
    }
}

class PowerUpManager {
    static let shared = PowerUpManager()
    
    private let defaults = UserDefaults.standard
    private let activePowerUpsKey = "activePowerUps"
    private let powerUpCountsKey = "powerUpCounts"
    
    private init() {}
    
    // MARK: - Active Power-ups
    
    private var activePowerUps: [PowerUpType: Int] {
        get {
            if let data = defaults.data(forKey: activePowerUpsKey),
               let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
                return Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
                    guard let powerUp = PowerUpType(rawValue: key) else { return nil }
                    return (powerUp, value)
                })
            }
            return [:]
        }
        set {
            let encoded = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.rawValue, $0.value) })
            if let data = try? JSONEncoder().encode(encoded) {
                defaults.set(data, forKey: activePowerUpsKey)
                defaults.synchronize()
            }
        }
    }
    
    // MARK: - Power-up Inventory
    
    func getPowerUpCount(_ type: PowerUpType) -> Int {
        let key = "\(powerUpCountsKey)_\(type.rawValue)"
        return defaults.integer(forKey: key)
    }
    
    func setPowerUpCount(_ type: PowerUpType, count: Int) {
        let key = "\(powerUpCountsKey)_\(type.rawValue)"
        defaults.set(max(0, count), forKey: key)
        defaults.synchronize()
    }
    
    func addPowerUp(_ type: PowerUpType, count: Int = 1) {
        let currentCount = getPowerUpCount(type)
        setPowerUpCount(type, count: currentCount + count)
    }
    
    func usePowerUp(_ type: PowerUpType) -> Bool {
        let currentCount = getPowerUpCount(type)
        if currentCount > 0 {
            setPowerUpCount(type, count: currentCount - 1)
            return true
        }
        return false
    }
    
    // MARK: - Power-up Purchase
    
    func canPurchase(_ type: PowerUpType) -> Bool {
        return GameSettings.shared.gems >= type.gemCost
    }
    
    func purchasePowerUp(_ type: PowerUpType) -> Bool {
        guard canPurchase(type) else { return false }
        
        GameSettings.shared.gems -= type.gemCost
        addPowerUp(type)
        return true
    }
    
    // MARK: - Active Power-up Management
    
    func activatePowerUp(_ type: PowerUpType) -> Bool {
        guard usePowerUp(type) else { return false }
        
        var active = activePowerUps
        let duration = getDuration(for: type)
        active[type] = duration
        activePowerUps = active
        
        return true
    }
    
    func isActive(_ type: PowerUpType) -> Bool {
        return (activePowerUps[type] ?? 0) > 0
    }
    
    func getRemainingDuration(_ type: PowerUpType) -> Int {
        return activePowerUps[type] ?? 0
    }
    
    private func getDuration(for type: PowerUpType) -> Int {
        switch type {
        case .colorHint: return 1 // One use
        case .scoreBoost: return 1 // One use
        case .streakProtect: return 1 // One use
        case .doubleCoins: return 5 // 5 matches
        case .timeFreeze: return 3 // 3 levels
        }
    }
    
    // MARK: - Power-up Effects
    
    func consumePowerUp(_ type: PowerUpType) {
        var active = activePowerUps
        if let remaining = active[type], remaining > 0 {
            if remaining == 1 {
                active.removeValue(forKey: type)
            } else {
                active[type] = remaining - 1
            }
            activePowerUps = active
        }
    }
    
    func getScoreMultiplier() -> Double {
        return isActive(.scoreBoost) ? 2.0 : 1.0
    }
    
    func getCoinMultiplier() -> Double {
        return isActive(.doubleCoins) ? 2.0 : 1.0
    }
    
    func hasStreakProtection() -> Bool {
        return isActive(.streakProtect)
    }
    
    func shouldShowColorHint() -> Bool {
        return isActive(.colorHint)
    }
    
    func hasTimeFreeze() -> Bool {
        return isActive(.timeFreeze)
    }
    
    // MARK: - Daily Rewards
    
    func awardDailyPowerUps() {
        // Award random power-ups for daily login
        let randomTypes = PowerUpType.allCases.shuffled().prefix(2)
        for type in randomTypes {
            addPowerUp(type, count: Int.random(in: 1...3))
        }
    }
    
    // MARK: - Achievement Rewards
    
    func awardAchievementPowerUps(_ achievement: String) {
        switch achievement {
        case "streak_5":
            addPowerUp(.colorHint, count: 1)
        case "streak_10":
            addPowerUp(.scoreBoost, count: 2)
        case "streak_20":
            addPowerUp(.streakProtect, count: 1)
        case "score_5000":
            addPowerUp(.doubleCoins, count: 3)
        default:
            break
        }
    }
    
    // MARK: - Reset Functions
    
    func clearAllActivePowerUps() {
        activePowerUps = [:]
    }
    
    func resetInventory() {
        for type in PowerUpType.allCases {
            setPowerUpCount(type, count: 0)
        }
        clearAllActivePowerUps()
    }
}