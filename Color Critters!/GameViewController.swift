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
            // Create the scene with proper size
            let scene = GameScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
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
        
        // Update scene size if needed
        if let view = self.view as? SKView, let scene = view.scene {
            scene.size = view.bounds.size
        }
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
