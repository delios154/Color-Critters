//
//  AdManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import Foundation
import UIKit

// MARK: - Ad Types
enum AdType {
    case interstitial
    case rewarded
}

// MARK: - Ad Delegate
protocol AdManagerDelegate: AnyObject {
    func adDidFinish()
    func adDidFail(with error: Error)
    func rewardedAdDidComplete()
}

class AdManager {
    static let shared = AdManager()
    
    weak var delegate: AdManagerDelegate?
    
    private var interstitialAd: Any? // Would be GADInterstitialAd in real implementation
    private var rewardedAd: Any? // Would be GADRewardedAd in real implementation
    private var isAdLoaded = false
    
    private init() {
        // Ads are disabled - no setup needed
        print("AdManager: Ads are disabled")
    }
    
    // MARK: - Setup
    private func setupAds() {
        // Ads are disabled - no setup needed
        print("AdManager: Ads are disabled")
    }
    
    // MARK: - Ad Loading
    func loadInterstitialAd() {
        // Ads are disabled - no loading needed
        print("AdManager: Ads are disabled - skipping interstitial ad load")
    }
    
    func loadRewardedAd() {
        // Ads are disabled - no loading needed
        print("AdManager: Ads are disabled - skipping rewarded ad load")
    }
    
    // MARK: - Ad Display
    func showInterstitialAd(from viewController: UIViewController) {
        // Ads are disabled - immediately call delegate to continue game flow
        print("AdManager: Ads are disabled - skipping interstitial")
        delegate?.adDidFinish()
    }
    
    func showRewardedAd(from viewController: UIViewController) {
        // Ads are disabled - immediately call delegate to continue game flow
        print("AdManager: Ads are disabled - skipping rewarded ad")
        delegate?.rewardedAdDidComplete()
    }
    
    // MARK: - Ad Status
    func isInterstitialAdReady() -> Bool {
        return false // Ads are disabled
    }
    
    func isRewardedAdReady() -> Bool {
        return false // Ads are disabled
    }
    
    // MARK: - Ad Frequency Control
    func shouldShowInterstitialAd() -> Bool {
        return false // Ads are disabled
    }
    
    // MARK: - Cleanup
    func cleanup() {
        interstitialAd = nil
        rewardedAd = nil
        isAdLoaded = false
    }
}

// MARK: - Ad Integration Helper
extension AdManager {
    func showAdIfNeeded(from viewController: UIViewController, type: AdType = .interstitial) {
        // Ads are disabled - immediately call appropriate delegate method
        switch type {
        case .interstitial:
            delegate?.adDidFinish()
        case .rewarded:
            delegate?.rewardedAdDidComplete()
        }
    }
    
    func offerRewardedAdForBonus(from viewController: UIViewController) {
        // Ads are disabled - immediately give bonus
        print("AdManager: Ads are disabled - giving bonus immediately")
        delegate?.rewardedAdDidComplete()
    }
} 