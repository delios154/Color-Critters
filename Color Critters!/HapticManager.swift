//
//  HapticManager.swift
//  Color Critters!
//
//  Created for haptic feedback management
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for faster response
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selection.prepare()
        notification.prepare()
    }
    
    // MARK: - Game Actions
    
    func dragStart() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }
    
    func correctMatch() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }
    
    func wrongMatch() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
    
    func levelComplete() {
        heavyImpact.impactOccurred()
        heavyImpact.prepare()
    }
    
    func streakMilestone() {
        // Double tap for streak milestone
        mediumImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mediumImpact.impactOccurred()
            self.mediumImpact.prepare()
        }
    }
    
    func powerUpActivated() {
        selection.selectionChanged()
        selection.prepare()
    }
    
    func buttonTap() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }
    
    func achievementUnlocked() {
        // Triple tap for achievement
        heavyImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heavyImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.heavyImpact.impactOccurred()
                self.heavyImpact.prepare()
            }
        }
    }
    
    func collectionComplete() {
        // Strong success pattern
        heavyImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.mediumImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.mediumImpact.impactOccurred()
                self.mediumImpact.prepare()
            }
        }
    }
    
    // MARK: - Settings
    
    private var isEnabled: Bool {
        get {
            return UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hapticFeedbackEnabled")
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    func isHapticEnabled() -> Bool {
        return isEnabled
    }
    
    // MARK: - Custom Patterns
    
    func customPattern(_ pattern: HapticPattern) {
        guard isEnabled else { return }
        
        switch pattern {
        case .gentle:
            lightImpact.impactOccurred()
        case .strong:
            heavyImpact.impactOccurred()
        case .celebration:
            // Custom celebration pattern
            heavyImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.mediumImpact.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.lightImpact.impactOccurred()
                }
            }
        }
        
        // Re-prepare generators
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
    }
}

enum HapticPattern {
    case gentle
    case strong
    case celebration
}