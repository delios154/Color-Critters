//
//  AnimalCollectionManager.swift
//  Color Critters!
//
//  Created for managing collected animals
//

import Foundation
import UIKit

struct CollectedAnimal {
    let name: String
    let color: UIColor
    let dateCollected: Date
    let level: Int
    
    var id: String {
        return "\(name)_\(colorName)"
    }
    
    var colorName: String {
        return AnimalCollectionManager.colorName(for: color)
    }
}

class AnimalCollectionManager {
    static let shared = AnimalCollectionManager()
    
    private let userDefaults = UserDefaults.standard
    private let collectionKey = "AnimalCollection"
    
    private init() {}
    
    // MARK: - Collection Management
    
    func addAnimal(name: String, color: UIColor, level: Int) {
        let animal = CollectedAnimal(name: name, color: color, dateCollected: Date(), level: level)
        var collection = getCollection()
        
        // Check if this exact combination already exists
        if !collection.contains(where: { $0.id == animal.id }) {
            collection.append(animal)
            saveCollection(collection)
        }
    }
    
    func getCollection() -> [CollectedAnimal] {
        guard let data = userDefaults.data(forKey: collectionKey),
              let collection = try? JSONDecoder().decode([CollectedAnimalData].self, from: data) else {
            return []
        }
        
        return collection.map { data in
            CollectedAnimal(
                name: data.name,
                color: UIColor(red: data.red, green: data.green, blue: data.blue, alpha: 1.0),
                dateCollected: data.dateCollected,
                level: data.level
            )
        }
    }
    
    private func saveCollection(_ collection: [CollectedAnimal]) {
        let collectionData = collection.map { animal in
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            animal.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return CollectedAnimalData(
                name: animal.name,
                red: red,
                green: green,
                blue: blue,
                dateCollected: animal.dateCollected,
                level: animal.level
            )
        }
        
        if let data = try? JSONEncoder().encode(collectionData) {
            userDefaults.set(data, forKey: collectionKey)
        }
    }
    
    // MARK: - Collection Stats
    
    func getCollectionStats() -> (total: Int, unique: Int, completion: Double) {
        let collection = getCollection()
        let total = collection.count
        let unique = Set(collection.map { $0.id }).count
        
        // Total possible combinations (10 animals × 10 colors = 100)
        let maxPossible = 100
        let completion = Double(unique) / Double(maxPossible)
        
        return (total: total, unique: unique, completion: completion)
    }
    
    func hasAnimal(name: String, color: UIColor) -> Bool {
        let collection = getCollection()
        let animalId = "\(name)_\(Self.colorName(for: color))"
        return collection.contains { $0.id == animalId }
    }
    
    func getAnimalsForName(_ name: String) -> [CollectedAnimal] {
        return getCollection().filter { $0.name == name }
    }
    
    func getAnimalsForColor(_ color: UIColor) -> [CollectedAnimal] {
        let colorName = Self.colorName(for: color)
        return getCollection().filter { $0.colorName == colorName }
    }
    
    // MARK: - Rewards and Achievements
    
    func checkForCollectionRewards() -> [CollectionReward] {
        let stats = getCollectionStats()
        var rewards: [CollectionReward] = []
        
        // Milestone rewards
        if stats.unique == 10 {
            rewards.append(.milestone("First 10 Animals!", 50))
        } else if stats.unique == 25 {
            rewards.append(.milestone("Quarter Collection!", 100))
        } else if stats.unique == 50 {
            rewards.append(.milestone("Half Complete!", 200))
        } else if stats.unique == 75 {
            rewards.append(.milestone("Three Quarters!", 300))
        } else if stats.unique == 100 {
            rewards.append(.milestone("Master Collector!", 500))
        }
        
        // Color completion rewards
        for color in getAllColors() {
            let colorAnimals = getAnimalsForColor(color)
            if colorAnimals.count == 10 { // All 10 animals in this color
                let colorName = Self.colorName(for: color)
                rewards.append(.colorComplete(colorName, 25))
            }
        }
        
        return rewards
    }
    
    // MARK: - Helper Methods
    
    static func colorName(for color: UIColor) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = round(red * 100) / 100
        let g = round(green * 100) / 100
        let b = round(blue * 100) / 100
        
        if r == 1.0 && g == 0.0 && b == 0.0 { return "Red" }
        if r == 0.0 && g == 0.0 && b == 1.0 { return "Blue" }
        if r == 0.0 && g == 1.0 && b == 0.0 { return "Green" }
        if r == 1.0 && g == 1.0 && b == 0.0 { return "Yellow" }
        if r == 1.0 && g == 0.5 && b == 0.0 { return "Orange" }
        if r == 0.5 && g == 0.0 && b == 0.5 { return "Purple" }
        if r == 1.0 && g == 0.18 && b == 0.33 { return "Pink" }
        if r == 0.6 && g == 0.4 && b == 0.2 { return "Brown" }
        if r == 0.0 && g == 1.0 && b == 1.0 { return "Cyan" }
        if r == 1.0 && g == 0.0 && b == 1.0 { return "Magenta" }
        
        return "Unknown"
    }
    
    private func getAllColors() -> [UIColor] {
        return [
            .red, .blue, .green, .yellow, .orange, .purple, 
            .systemPink, .brown, .cyan, .magenta
        ]
    }
}

// MARK: - Data Models

private struct CollectedAnimalData: Codable {
    let name: String
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let dateCollected: Date
    let level: Int
}

enum CollectionReward {
    case milestone(String, Int) // title, coins
    case colorComplete(String, Int) // color name, coins
    
    var title: String {
        switch self {
        case .milestone(let title, _):
            return title
        case .colorComplete(let color, _):
            return "\(color) Collection Complete!"
        }
    }
    
    var coins: Int {
        switch self {
        case .milestone(_, let coins):
            return coins
        case .colorComplete(_, let coins):
            return coins
        }
    }
}