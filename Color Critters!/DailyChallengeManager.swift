//
//  DailyChallengeManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import Foundation

enum ChallengeType: String, CaseIterable, Codable {
    case colorMaster = "color_master"
    case streakHero = "streak_hero"
    case speedRun = "speed_run"
    case perfectRound = "perfect_round"
    case critterCollector = "critter_collector"
    
    var title: String {
        switch self {
        case .colorMaster: return "Color Master"
        case .streakHero: return "Streak Hero"
        case .speedRun: return "Speed Run"
        case .perfectRound: return "Perfect Round"
        case .critterCollector: return "Critter Collector"
        }
    }
    
    var description: String {
        switch self {
        case .colorMaster: return "Match 20 colors correctly"
        case .streakHero: return "Achieve a 10-color streak"
        case .speedRun: return "Complete 5 levels in under 2 minutes"
        case .perfectRound: return "Complete 10 matches with 100% accuracy"
        case .critterCollector: return "Color 8 different critters"
        }
    }
    
    var icon: String {
        switch self {
        case .colorMaster: return "🎨"
        case .streakHero: return "🔥"
        case .speedRun: return "⚡"
        case .perfectRound: return "💯"
        case .critterCollector: return "🦊"
        }
    }
    
    var reward: ChallengeReward {
        switch self {
        case .colorMaster: return ChallengeReward(coins: 50, gems: 3, xp: 100)
        case .streakHero: return ChallengeReward(coins: 75, gems: 5, xp: 150)
        case .speedRun: return ChallengeReward(coins: 60, gems: 4, xp: 120)
        case .perfectRound: return ChallengeReward(coins: 80, gems: 6, xp: 180)
        case .critterCollector: return ChallengeReward(coins: 40, gems: 2, xp: 80)
        }
    }
}

struct ChallengeReward: Codable {
    let coins: Int
    let gems: Int
    let xp: Int
}

struct DailyChallenge: Codable {
    let type: ChallengeType
    let target: Int
    var progress: Int
    let reward: ChallengeReward
    var isCompleted: Bool
    let date: Date
    
    var progressPercentage: Double {
        return min(1.0, Double(progress) / Double(target))
    }
    
    var progressText: String {
        return "\(progress)/\(target)"
    }
    
    mutating func updateProgress(by amount: Int) {
        progress = min(target, progress + amount)
        if progress >= target && !isCompleted {
            isCompleted = true
        }
    }
}

class DailyChallengeManager {
    static let shared = DailyChallengeManager()
    
    private let defaults = UserDefaults.standard
    private let challengesKey = "dailyChallenges"
    private let lastChallengeResetKey = "lastChallengeReset"
    private let completedChallengesKey = "completedChallenges"
    
    private init() {
        checkForDailyReset()
    }
    
    // MARK: - Daily Challenge Management
    
    func getCurrentChallenges() -> [DailyChallenge] {
        if let data = defaults.data(forKey: challengesKey),
           let challenges = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            return challenges
        }
        return generateDailyChallenges()
    }
    
    private func saveChallenges(_ challenges: [DailyChallenge]) {
        if let data = try? JSONEncoder().encode(challenges) {
            defaults.set(data, forKey: challengesKey)
            defaults.synchronize()
        }
    }
    
    private func generateDailyChallenges() -> [DailyChallenge] {
        let challengeTypes = ChallengeType.allCases.shuffled().prefix(3)
        let today = Date()
        
        let challenges = challengeTypes.map { type in
            DailyChallenge(
                type: type,
                target: getTargetValue(for: type),
                progress: 0,
                reward: type.reward,
                isCompleted: false,
                date: today
            )
        }
        
        saveChallenges(Array(challenges))
        return Array(challenges)
    }
    
    private func getTargetValue(for type: ChallengeType) -> Int {
        switch type {
        case .colorMaster: return 20
        case .streakHero: return 10
        case .speedRun: return 5
        case .perfectRound: return 10
        case .critterCollector: return 8
        }
    }
    
    // MARK: - Challenge Progress Tracking
    
    func updateChallengeProgress(_ type: ChallengeType, progress: Int) {
        var challenges = getCurrentChallenges()
        
        for i in 0..<challenges.count {
            if challenges[i].type == type && !challenges[i].isCompleted {
                let wasCompleted = challenges[i].isCompleted
                challenges[i].updateProgress(by: progress)
                
                // Award rewards if just completed
                if !wasCompleted && challenges[i].isCompleted {
                    awardChallengeReward(challenges[i].reward)
                    recordCompletedChallenge(type)
                }
                break
            }
        }
        
        saveChallenges(challenges)
    }
    
    func updateColorMasterProgress() {
        updateChallengeProgress(.colorMaster, progress: 1)
    }
    
    func updateStreakProgress(_ streak: Int) {
        if streak >= 10 {
            updateChallengeProgress(.streakHero, progress: 1)
        }
    }
    
    func updateSpeedRunProgress(_ levelsCompleted: Int, timeElapsed: TimeInterval) {
        if levelsCompleted >= 5 && timeElapsed < 120 { // 2 minutes
            updateChallengeProgress(.speedRun, progress: 1)
        }
    }
    
    func updatePerfectRoundProgress(_ consecutiveCorrect: Int) {
        if consecutiveCorrect >= 10 {
            updateChallengeProgress(.perfectRound, progress: 1)
        }
    }
    
    func updateCritterCollectorProgress(_ critterName: String) {
        // Track unique critters in UserDefaults
        let key = "todaysCritters"
        var critters = defaults.stringArray(forKey: key) ?? []
        
        if !critters.contains(critterName) {
            critters.append(critterName)
            defaults.set(critters, forKey: key)
            updateChallengeProgress(.critterCollector, progress: 1)
        }
    }
    
    // MARK: - Reward System
    
    private func awardChallengeReward(_ reward: ChallengeReward) {
        let settings = GameSettings.shared
        settings.coins += reward.coins
        settings.gems += reward.gems
        settings.experiencePoints += reward.xp
        
        // Award bonus power-ups
        PowerUpManager.shared.addPowerUp(.colorHint, count: 1)
    }
    
    private func recordCompletedChallenge(_ type: ChallengeType) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: Date())
        let key = "\(completedChallengesKey)_\(dateKey)_\(type.rawValue)"
        defaults.set(true, forKey: key)
    }
    
    // MARK: - Daily Reset Logic
    
    private func checkForDailyReset() {
        let today = Date()
        let lastReset = defaults.object(forKey: lastChallengeResetKey) as? Date ?? Date.distantPast
        
        let calendar = Calendar.current
        if !calendar.isDate(today, inSameDayAs: lastReset) {
            performDailyReset()
            defaults.set(today, forKey: lastChallengeResetKey)
        }
    }
    
    private func performDailyReset() {
        // Clear today's critter collection
        defaults.removeObject(forKey: "todaysCritters")
        
        // Generate new challenges
        let _ = generateDailyChallenges()
        
        // Award daily login rewards
        awardDailyLoginRewards()
    }
    
    private func awardDailyLoginRewards() {
        let settings = GameSettings.shared
        settings.coins += 25
        settings.gems += 1
        
        // Award daily power-ups
        PowerUpManager.shared.awardDailyPowerUps()
    }
    
    // MARK: - Statistics
    
    func getCompletionStats() -> (completed: Int, total: Int) {
        let challenges = getCurrentChallenges()
        let completed = challenges.filter { $0.isCompleted }.count
        return (completed, challenges.count)
    }
    
    func getTotalRewardsEarned() -> ChallengeReward {
        let challenges = getCurrentChallenges()
        let completedChallenges = challenges.filter { $0.isCompleted }
        
        let totalCoins = completedChallenges.reduce(0) { $0 + $1.reward.coins }
        let totalGems = completedChallenges.reduce(0) { $0 + $1.reward.gems }
        let totalXP = completedChallenges.reduce(0) { $0 + $1.reward.xp }
        
        return ChallengeReward(coins: totalCoins, gems: totalGems, xp: totalXP)
    }
    
    func getAllTimeCompletionCount() -> Int {
        let allKeys = defaults.dictionaryRepresentation().keys
        let completedKeys = allKeys.filter { $0.hasPrefix(completedChallengesKey) }
        return completedKeys.count
    }
}