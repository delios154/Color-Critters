//
//  GenerateAnimalImages.swift
//  Script to generate placeholder animal images
//

import UIKit
import Foundation

class GenerateAnimalImages {
    static func generateAllImages() {
        let animals = ["frog", "cat", "dog", "rabbit", "elephant", "giraffe", "lion", "tiger", "bear", "penguin"]
        let baseSize = CGSize(width: 140, height: 140)
        
        for animal in animals {
            // Generate 1x image
            if let image1x = AnimalImageGenerator.generateAnimalImage(for: animal, size: baseSize) {
                saveImageToAssets(image: image1x, named: "\(animal).png", animal: animal)
            }
            
            // Generate 2x image
            let size2x = CGSize(width: baseSize.width * 2, height: baseSize.height * 2)
            if let image2x = AnimalImageGenerator.generateAnimalImage(for: animal, size: size2x) {
                saveImageToAssets(image: image2x, named: "\(animal)@2x.png", animal: animal)
            }
            
            // Generate 3x image
            let size3x = CGSize(width: baseSize.width * 3, height: baseSize.height * 3)
            if let image3x = AnimalImageGenerator.generateAnimalImage(for: animal, size: size3x) {
                saveImageToAssets(image: image3x, named: "\(animal)@3x.png", animal: animal)
            }
        }
    }
    
    private static func saveImageToAssets(image: UIImage, named filename: String, animal: String) {
        guard let data = image.pngData() else { return }
        
        // Create the path to the asset folder
        let bundle = Bundle.main
        if let bundlePath = bundle.path(forResource: "Assets", ofType: "xcassets") {
            let animalPath = "\(bundlePath)/Animals/\(animal).imageset/\(filename)"
            let url = URL(fileURLWithPath: animalPath)
            
            do {
                try data.write(to: url)
                print("Saved: \(filename) for \(animal)")
            } catch {
                print("Failed to save \(filename): \(error)")
            }
        }
    }
}

// Extension to help with document directory saving during development
extension GenerateAnimalImages {
    static func saveImagesToDocuments() {
        let animals = ["frog", "cat", "dog", "rabbit", "elephant", "giraffe", "lion", "tiger", "bear", "penguin"]
        let baseSize = CGSize(width: 140, height: 140)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for animal in animals {
            // Generate and save 1x image
            if let image1x = AnimalImageGenerator.generateAnimalImage(for: animal, size: baseSize),
               let data1x = image1x.pngData() {
                let url1x = documentsPath.appendingPathComponent("\(animal).png")
                try? data1x.write(to: url1x)
            }
            
            // Generate and save 2x image
            let size2x = CGSize(width: baseSize.width * 2, height: baseSize.height * 2)
            if let image2x = AnimalImageGenerator.generateAnimalImage(for: animal, size: size2x),
               let data2x = image2x.pngData() {
                let url2x = documentsPath.appendingPathComponent("\(animal)@2x.png")
                try? data2x.write(to: url2x)
            }
            
            // Generate and save 3x image
            let size3x = CGSize(width: baseSize.width * 3, height: baseSize.height * 3)
            if let image3x = AnimalImageGenerator.generateAnimalImage(for: animal, size: size3x),
               let data3x = image3x.pngData() {
                let url3x = documentsPath.appendingPathComponent("\(animal)@3x.png")
                try? data3x.write(to: url3x)
            }
        }
        
        print("Images saved to Documents directory: \(documentsPath.path)")
    }
} 