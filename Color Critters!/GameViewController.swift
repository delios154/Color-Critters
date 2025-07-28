//
//  GameViewController.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        if let view = self.view as! SKView? {
            // Use a standard size for consistent gameplay across devices
            let sceneSize = CGSize(width: 390, height: 844) // iPhone 14 size as base
            let scene = GameScene(size: sceneSize)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFit
            
            // Present the scene
            view.presentScene(scene)
            
            // Configure view settings
            view.ignoresSiblingOrder = true
            
            // Enable debugging in development
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false
            #endif
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure proper orientation
        if let window = view.window {
            window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Keep the scene size consistent for better gameplay
        // The scene will scale to fit the view automatically
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Force portrait mode for better gameplay experience
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
