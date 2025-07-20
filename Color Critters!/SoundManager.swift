//
//  SoundManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import AVFoundation
import SpriteKit

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var isSoundEnabled = true
    private var isMusicEnabled = true
    
    private init() {
        setupAudioSession()
        loadSettings()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadSettings() {
        let settings = GameSettings.shared
        isSoundEnabled = settings.isSoundEnabled
        isMusicEnabled = settings.isMusicEnabled
    }
    
    // MARK: - Sound Effects
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        
        // Create a cheerful ascending tone for correct answers
        let sampleRate: Double = 44100
        let duration: Double = 0.4
        let startFreq: Double = 600
        let endFreq: Double = 1200
        
        let frameCount = Int(sampleRate * duration)
        let audioData = NSMutableData()
        
        for i in 0..<frameCount {
            let progress = Double(i) / Double(frameCount)
            let frequency = startFreq + (endFreq - startFreq) * progress
            let sample = sin(2.0 * Double.pi * frequency * Double(i) / sampleRate)
            var sample16 = Int16(sample * 24575)
            audioData.append(&sample16, length: MemoryLayout<Int16>.size)
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData as Data)
            player.volume = 0.6
            player.play()
            audioPlayers["correct"] = player
        } catch {
            print("Failed to play correct sound: \(error)")
        }
    }
    
    func playWrongSound() {
        guard isSoundEnabled else { return }
        
        // Create a gentle descending tone for wrong answers
        let sampleRate: Double = 44100
        let duration: Double = 0.3
        let startFreq: Double = 500
        let endFreq: Double = 300
        
        let frameCount = Int(sampleRate * duration)
        let audioData = NSMutableData()
        
        for i in 0..<frameCount {
            let progress = Double(i) / Double(frameCount)
            let frequency = startFreq + (endFreq - startFreq) * progress
            let sample = sin(2.0 * Double.pi * frequency * Double(i) / sampleRate)
            var sample16 = Int16(sample * 16383) // Lower volume
            audioData.append(&sample16, length: MemoryLayout<Int16>.size)
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData as Data)
            player.volume = 0.4
            player.play()
            audioPlayers["wrong"] = player
        } catch {
            print("Failed to play wrong sound: \(error)")
        }
    }
    
    func playLevelUpSound() {
        guard isSoundEnabled else { return }
        
        // Create a celebratory ascending arpeggio
        let sampleRate: Double = 44100
        let duration: Double = 0.8
        let frequencies: [Double] = [400, 500, 600, 800, 1000]
        let notesPerSecond = 5.0
        
        let frameCount = Int(sampleRate * duration)
        let audioData = NSMutableData()
        
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let noteIndex = Int(time * notesPerSecond) % frequencies.count
            let frequency = frequencies[noteIndex]
            let sample = sin(2.0 * Double.pi * frequency * time)
            var sample16 = Int16(sample * 24575)
            audioData.append(&sample16, length: MemoryLayout<Int16>.size)
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData as Data)
            player.volume = 0.7
            player.play()
            audioPlayers["levelUp"] = player
        } catch {
            print("Failed to play level up sound: \(error)")
        }
    }
    
    func playTapSound() {
        guard isSoundEnabled else { return }
        
        // Create a gentle tap sound
        let sampleRate: Double = 44100
        let duration: Double = 0.1
        let frequency: Double = 800
        
        let frameCount = Int(sampleRate * duration)
        let audioData = NSMutableData()
        
        for i in 0..<frameCount {
            let sample = sin(2.0 * Double.pi * frequency * Double(i) / sampleRate)
            var sample16 = Int16(sample * 16383)
            audioData.append(&sample16, length: MemoryLayout<Int16>.size)
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData as Data)
            player.volume = 0.3
            player.play()
            audioPlayers["tap"] = player
        } catch {
            print("Failed to play tap sound: \(error)")
        }
    }
    
    func playBonusSound() {
        guard isSoundEnabled else { return }
        
        // Create a magical bonus sound
        let sampleRate: Double = 44100
        let duration: Double = 0.6
        let frequencies: [Double] = [800, 1000, 1200, 1000, 800]
        let notesPerSecond = 8.0
        
        let frameCount = Int(sampleRate * duration)
        let audioData = NSMutableData()
        
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let noteIndex = Int(time * notesPerSecond) % frequencies.count
            let frequency = frequencies[noteIndex]
            let sample = sin(2.0 * Double.pi * frequency * time)
            var sample16 = Int16(sample * 24575)
            audioData.append(&sample16, length: MemoryLayout<Int16>.size)
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData as Data)
            player.volume = 0.6
            player.play()
            audioPlayers["bonus"] = player
        } catch {
            print("Failed to play bonus sound: \(error)")
        }
    }
    
    // MARK: - Background Music
    func startBackgroundMusic() {
        guard isMusicEnabled else { return }
        
        // Create a simple, cheerful background melody
        let sampleRate: Double = 44100
        let duration: Double = 10.0 // Loop every 10 seconds
        let frequencies: [Double] = [262, 330, 392, 523, 392, 330] // C major scale
        let notesPerSecond = 1.0
        
        let frameCount = Int(sampleRate * duration)
        let audioData = NSMutableData()
        
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let noteIndex = Int(time * notesPerSecond) % frequencies.count
            let frequency = frequencies[noteIndex]
            let sample = sin(2.0 * Double.pi * frequency * time)
            var sample16 = Int16(sample * 8191) // Very low volume for background
            audioData.append(&sample16, length: MemoryLayout<Int16>.size)
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData as Data)
            player.volume = 0.2
            player.numberOfLoops = -1 // Infinite loop
            player.play()
            backgroundMusicPlayer = player
        } catch {
            print("Failed to start background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    // MARK: - Settings
    func toggleSound() {
        isSoundEnabled.toggle()
        GameSettings.shared.isSoundEnabled = isSoundEnabled
        
        if !isSoundEnabled {
            stopAllSounds()
        }
    }
    
    func toggleMusic() {
        isMusicEnabled.toggle()
        GameSettings.shared.isMusicEnabled = isMusicEnabled
        
        if isMusicEnabled {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }
    
    func isSoundOn() -> Bool {
        return isSoundEnabled
    }
    
    func isMusicOn() -> Bool {
        return isMusicEnabled
    }
    
    // MARK: - Cleanup
    func stopAllSounds() {
        for (_, player) in audioPlayers {
            player.stop()
        }
        audioPlayers.removeAll()
    }
    
    func stopAllAudio() {
        stopAllSounds()
        stopBackgroundMusic()
    }
    
    // MARK: - Audio Session Management
    func handleAppDidEnterBackground() {
        // Reduce volume when app goes to background
        backgroundMusicPlayer?.volume = 0.1
    }
    
    func handleAppWillEnterForeground() {
        // Restore volume when app comes to foreground
        if isMusicEnabled {
            backgroundMusicPlayer?.volume = 0.2
        }
    }
} 