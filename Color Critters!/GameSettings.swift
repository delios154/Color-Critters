//
//  GameSettings.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import Foundation

class GameSettings {
    static let shared = GameSettings()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private let highScoreKey = "highScore"
    private let currentLevelKey = "currentLevel"
    private let totalScoreKey = "totalScore"
    private let correctMatchesKey = "correctMatches"
    private let totalMatchesKey = "totalMatches"
    private let soundEnabledKey = "soundEnabled"
    private let musicEnabledKey = "musicEnabled"
    private let adsRemovedKey = "adsRemoved"
    private let tutorialCompletedKey = "tutorialCompleted"
    private let currentStreakKey = "currentStreak"
    private let bestStreakKey = "bestStreak"
    private let streakMultiplierKey = "streakMultiplier"
    private let coinsKey = "coins"
    private let gemsKey = "gems"
    private let unlockedCrittersKey = "unlockedCritters"
    private let unlockedColorsKey = "unlockedColors"
    private let achievementsKey = "achievements"
    private let dailyChallengesKey = "dailyChallenges"
    private let lastPlayDateKey = "lastPlayDate"
    private let experiencePointsKey = "experiencePoints"
    private let playerLevelKey = "playerLevel"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    private init() {}
    
    // MARK: - Game Progress
    var highScore: Int {
        get { defaults.integer(forKey: highScoreKey) }
        set { 
            defaults.set(newValue, forKey: highScoreKey)
            defaults.synchronize()
        }
    }
    
    var currentLevel: Int {
        get { defaults.integer(forKey: currentLevelKey) }
        set { 
            defaults.set(newValue, forKey: currentLevelKey)
            defaults.synchronize()
        }
    }
    
    var totalScore: Int {
        get { defaults.integer(forKey: totalScoreKey) }
        set { 
            defaults.set(newValue, forKey: totalScoreKey)
            defaults.synchronize()
        }
    }
    
    var correctMatches: Int {
        get { defaults.integer(forKey: correctMatchesKey) }
        set { 
            defaults.set(newValue, forKey: correctMatchesKey)
            defaults.synchronize()
        }
    }
    
    var totalMatches: Int {
        get { defaults.integer(forKey: totalMatchesKey) }
        set { 
            defaults.set(newValue, forKey: totalMatchesKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Settings
    var isSoundEnabled: Bool {
        get { defaults.bool(forKey: soundEnabledKey) }
        set { 
            defaults.set(newValue, forKey: soundEnabledKey)
            defaults.synchronize()
        }
    }
    
    var isMusicEnabled: Bool {
        get { defaults.bool(forKey: musicEnabledKey) }
        set { 
            defaults.set(newValue, forKey: musicEnabledKey)
            defaults.synchronize()
        }
    }
    
    var areAdsRemoved: Bool {
        get { defaults.object(forKey: adsRemovedKey) == nil ? true : defaults.bool(forKey: adsRemovedKey) }
        set { 
            defaults.set(newValue, forKey: adsRemovedKey)
            defaults.synchronize()
        }
    }
    
    var hasCompletedTutorial: Bool {
        get { defaults.bool(forKey: tutorialCompletedKey) }
        set { 
            defaults.set(newValue, forKey: tutorialCompletedKey)
            defaults.synchronize()
        }
    }
    
    var hasSeenTutorial: Bool {
        get { defaults.bool(forKey: tutorialCompletedKey) }
        set { 
            defaults.set(newValue, forKey: tutorialCompletedKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Gamification Features
    var currentStreak: Int {
        get { defaults.integer(forKey: currentStreakKey) }
        set { 
            defaults.set(newValue, forKey: currentStreakKey)
            if newValue > bestStreak {
                bestStreak = newValue
            }
            defaults.synchronize()
        }
    }
    
    var bestStreak: Int {
        get { defaults.integer(forKey: bestStreakKey) }
        set { 
            defaults.set(newValue, forKey: bestStreakKey)
            defaults.synchronize()
        }
    }
    
    var streakMultiplier: Double {
        get { defaults.double(forKey: streakMultiplierKey) == 0 ? 1.0 : defaults.double(forKey: streakMultiplierKey) }
        set { 
            defaults.set(newValue, forKey: streakMultiplierKey)
            defaults.synchronize()
        }
    }
    
    var coins: Int {
        get { defaults.integer(forKey: coinsKey) }
        set { 
            defaults.set(newValue, forKey: coinsKey)
            defaults.synchronize()
        }
    }
    
    var gems: Int {
        get { defaults.integer(forKey: gemsKey) }
        set { 
            defaults.set(newValue, forKey: gemsKey)
            defaults.synchronize()
        }
    }
    
    var unlockedCritters: Set<String> {
        get { 
            if let data = defaults.array(forKey: unlockedCrittersKey) as? [String] {
                return Set(data)
            }
            return Set(["frog", "cat", "dog"]) // Default unlocked critters
        }
        set { 
            defaults.set(Array(newValue), forKey: unlockedCrittersKey)
            defaults.synchronize()
        }
    }
    
    var unlockedColors: Set<String> {
        get { 
            if let data = defaults.array(forKey: unlockedColorsKey) as? [String] {
                return Set(data)
            }
            return Set(["red", "blue", "green", "yellow"]) // Default unlocked colors
        }
        set { 
            defaults.set(Array(newValue), forKey: unlockedColorsKey)
            defaults.synchronize()
        }
    }
    
    var unlockedAchievements: Set<String> {
        get { 
            if let data = defaults.array(forKey: achievementsKey) as? [String] {
                return Set(data)
            }
            return Set()
        }
        set { 
            defaults.set(Array(newValue), forKey: achievementsKey)
            defaults.synchronize()
        }
    }
    
    var experiencePoints: Int {
        get { defaults.integer(forKey: experiencePointsKey) }
        set { 
            defaults.set(newValue, forKey: experiencePointsKey)
            defaults.synchronize()
        }
    }
    
    var playerLevel: Int {
        get { defaults.integer(forKey: playerLevelKey) == 0 ? 1 : defaults.integer(forKey: playerLevelKey) }
        set { 
            defaults.set(newValue, forKey: playerLevelKey)
            defaults.synchronize()
        }
    }
    
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: hasCompletedOnboardingKey) }
        set {
            defaults.set(newValue, forKey: hasCompletedOnboardingKey)
            defaults.synchronize()
        }
    }
    
    var lastPlayDate: Date? {
        get { defaults.object(forKey: lastPlayDateKey) as? Date }
        set { 
            defaults.set(newValue, forKey: lastPlayDateKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Game Logic
    func updateScore(_ newScore: Int) {
        let multipliedScore = Int(Double(newScore) * streakMultiplier)
        totalScore += multipliedScore
        if multipliedScore > highScore {
            highScore = multipliedScore
        }
        
        // Award experience points
        experiencePoints += multipliedScore / 10
        checkLevelUp()
        
        // Award coins
        coins += multipliedScore / 100 + 1
    }
    
    func updateMatchStats(correct: Bool) {
        totalMatches += 1
        if correct {
            correctMatches += 1
            currentStreak += 1
            updateStreakMultiplier()
        } else {
            currentStreak = 0
            streakMultiplier = 1.0
        }
        checkAchievements()
    }
    
    private func updateStreakMultiplier() {
        if currentStreak >= 10 {
            streakMultiplier = 3.0
        } else if currentStreak >= 5 {
            streakMultiplier = 2.0
        } else if currentStreak >= 3 {
            streakMultiplier = 1.5
        } else {
            streakMultiplier = 1.0
        }
    }
    
    private func checkLevelUp() {
        let requiredXP = playerLevel * 100
        if experiencePoints >= requiredXP {
            playerLevel += 1
            gems += 5 // Reward gems for leveling up
            checkForUnlocks()
        }
    }
    
    private func checkForUnlocks() {
        let allCritters = ["frog", "cat", "dog", "rabbit", "elephant", "giraffe", "lion", "tiger", "bear", "penguin"]
        let allColors = ["red", "blue", "green", "yellow", "orange", "purple", "pink", "brown", "cyan", "magenta"]
        
        // Unlock critters based on level
        if playerLevel >= 3 && !unlockedCritters.contains("rabbit") {
            var unlocked = unlockedCritters
            unlocked.insert("rabbit")
            unlockedCritters = unlocked
        }
        if playerLevel >= 5 && !unlockedCritters.contains("elephant") {
            var unlocked = unlockedCritters
            unlocked.insert("elephant")
            unlockedCritters = unlocked
        }
        if playerLevel >= 8 && !unlockedCritters.contains("giraffe") {
            var unlocked = unlockedCritters
            unlocked.insert("giraffe")
            unlockedCritters = unlocked
        }
        
        // Unlock colors based on level
        if playerLevel >= 2 && !unlockedColors.contains("orange") {
            var unlocked = unlockedColors
            unlocked.insert("orange")
            unlockedColors = unlocked
        }
        if playerLevel >= 4 && !unlockedColors.contains("purple") {
            var unlocked = unlockedColors
            unlocked.insert("purple")
            unlockedColors = unlocked
        }
    }
    
    private func checkAchievements() {
        var newAchievements = unlockedAchievements
        
        // Streak achievements
        if currentStreak >= 5 && !newAchievements.contains("streak_5") {
            newAchievements.insert("streak_5")
            gems += 3
        }
        if currentStreak >= 10 && !newAchievements.contains("streak_10") {
            newAchievements.insert("streak_10")
            gems += 5
        }
        if currentStreak >= 20 && !newAchievements.contains("streak_20") {
            newAchievements.insert("streak_20")
            gems += 10
        }
        
        // Score achievements
        if totalScore >= 1000 && !newAchievements.contains("score_1000") {
            newAchievements.insert("score_1000")
            gems += 5
        }
        if totalScore >= 5000 && !newAchievements.contains("score_5000") {
            newAchievements.insert("score_5000")
            gems += 10
        }
        
        // Accuracy achievements
        let accuracy = getAccuracy()
        if accuracy >= 90 && totalMatches >= 50 && !newAchievements.contains("accuracy_90") {
            newAchievements.insert("accuracy_90")
            gems += 7
        }
        
        unlockedAchievements = newAchievements
    }
    
    func getAccuracy() -> Double {
        guard totalMatches > 0 else { return 0.0 }
        return Double(correctMatches) / Double(totalMatches) * 100.0
    }
    
    func shouldShowAd() -> Bool {
        // Ads are disabled - never show ads
        return false
    }
    
    func resetGame() {
        currentLevel = 1
        totalScore = 0
        correctMatches = 0
        totalMatches = 0
        currentStreak = 0
        streakMultiplier = 1.0
        // Don't reset high score, sound, music, ads settings, or gamification progress
    }
    
    func resetAllData() {
        defaults.removeObject(forKey: highScoreKey)
        defaults.removeObject(forKey: currentLevelKey)
        defaults.removeObject(forKey: totalScoreKey)
        defaults.removeObject(forKey: correctMatchesKey)
        defaults.removeObject(forKey: totalMatchesKey)
        defaults.removeObject(forKey: soundEnabledKey)
        defaults.removeObject(forKey: musicEnabledKey)
        defaults.removeObject(forKey: adsRemovedKey)
        defaults.removeObject(forKey: tutorialCompletedKey)
        defaults.synchronize()
    }
} 