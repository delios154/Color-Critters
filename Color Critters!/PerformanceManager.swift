//
//  PerformanceManager.swift
//  Color Critters!
//
//  Created by Mohammed Almansoori on 20/07/2025.
//

import SpriteKit

class PerformanceManager {
    static let shared = PerformanceManager()
    
    private var textureCache: [String: SKTexture] = [:]
    private var nodePool: [String: [SKNode]] = [:]
    private let maxPoolSize = 20
    
    private init() {}
    
    // MARK: - Texture Management
    
    func preloadTextures(named names: [String]) {
        for name in names {
            if textureCache[name] == nil {
                let texture = SKTexture(imageNamed: name)
                texture.preload {
                    self.textureCache[name] = texture
                }
            }
        }
    }
    
    func getTexture(named name: String) -> SKTexture {
        if let cachedTexture = textureCache[name] {
            return cachedTexture
        }
        
        let texture = SKTexture(imageNamed: name)
        textureCache[name] = texture
        return texture
    }
    
    func clearTextureCache() {
        textureCache.removeAll()
    }
    
    // MARK: - Node Pooling
    
    func getPooledNode(type: String, creator: () -> SKNode) -> SKNode {
        if let pool = nodePool[type], !pool.isEmpty {
            var node = pool[0]
            nodePool[type]?.removeFirst()
            resetNode(node)
            return node
        }
        
        return creator()
    }
    
    func returnNodeToPool(node: SKNode, type: String) {
        resetNode(node)
        
        if nodePool[type] == nil {
            nodePool[type] = []
        }
        
        if let pool = nodePool[type], pool.count < maxPoolSize {
            nodePool[type]?.append(node)
        }
    }
    
    private func resetNode(_ node: SKNode) {
        node.removeFromParent()
        node.removeAllActions()
        node.removeAllChildren()
        node.alpha = 1.0
        node.zRotation = 0
        node.xScale = 1.0
        node.yScale = 1.0
        node.position = .zero
        node.isHidden = false
        node.isPaused = false
    }
    
    // MARK: - Batch Operations
    
    func batchAddChildren(_ children: [SKNode], to parent: SKNode) {
        parent.speed = 0
        for child in children {
            parent.addChild(child)
        }
        parent.speed = 1
    }
    
    func batchRemoveChildren(_ children: [SKNode]) {
        for child in children {
            child.speed = 0
            child.removeFromParent()
        }
    }
    
    // MARK: - Performance Monitoring
    
    func measurePerformance(name: String, block: () -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #if DEBUG
        if timeElapsed > 0.016 { // More than 16ms (60fps threshold)
            print("⚠️ Performance Warning: \(name) took \(timeElapsed * 1000)ms")
        }
        #endif
    }
    
    // MARK: - Memory Management
    
    func optimizeMemoryUsage() {
        // Clear unused textures
        let maxCacheSize = 50
        if textureCache.count > maxCacheSize {
            let keysToRemove = Array(textureCache.keys.prefix(textureCache.count - maxCacheSize))
            for key in keysToRemove {
                textureCache.removeValue(forKey: key)
            }
        }
        
        // Clear oversized node pools
        for (type, pool) in nodePool {
            if pool.count > maxPoolSize / 2 {
                let nodesToRemove = pool.count - maxPoolSize / 2
                nodePool[type]?.removeLast(nodesToRemove)
            }
        }
    }
    
    // MARK: - Rendering Optimization
    
    func optimizeScene(_ scene: SKScene) {
        // Enable texture atlasing
        scene.view?.ignoresSiblingOrder = true
        
        // Set optimal rendering settings
        scene.view?.showsFPS = false
        scene.view?.showsNodeCount = false
        scene.view?.showsPhysics = false
        scene.view?.showsFields = false
        scene.view?.showsQuadCount = false
        scene.view?.showsDrawCount = false
        
        #if DEBUG
        // Show performance metrics in debug builds
        scene.view?.showsFPS = true
        scene.view?.showsNodeCount = true
        scene.view?.showsDrawCount = true
        #endif
        
        // Enable multi-threading
        scene.view?.isAsynchronous = true
        
        // Set frame rate
        scene.view?.preferredFramesPerSecond = 60
    }
    
    // MARK: - Culling
    
    func cullOffscreenNodes(in scene: SKScene) {
        let visibleRect = scene.frame
        
        scene.enumerateChildNodes(withName: "//*") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let nodeFrame = sprite.frame
                let isVisible = visibleRect.intersects(nodeFrame)
                sprite.isHidden = !isVisible
            }
        }
    }
    
    // MARK: - Action Optimization
    
    func createOptimizedAction(_ action: SKAction) -> SKAction {
        // Cache common actions
        if let cachedAction = getFromActionCache(action) {
            return cachedAction
        }
        
        // For complex sequences, optimize timing
        action.speed = 1.0
        action.timingMode = .linear // Use easing only when necessary
        
        cacheAction(action)
        return action
    }
    
    private var actionCache: [String: SKAction] = [:]
    
    private func getFromActionCache(_ action: SKAction) -> SKAction? {
        let key = String(describing: action)
        return actionCache[key]
    }
    
    private func cacheAction(_ action: SKAction) {
        let key = String(describing: action)
        if actionCache.count < 100 { // Limit cache size
            actionCache[key] = action
        }
    }
    
    // MARK: - Batch Texture Loading
    
    func preloadGameAssets(completion: @escaping () -> Void) {
        let assetsToLoad = [
            // Critter textures
            "frog", "cat", "dog", "rabbit", "elephant",
            "giraffe", "lion", "tiger", "bear", "penguin",
            
            // UI elements
            "pause_button", "play_button", "settings_icon",
            "star_filled", "star_empty", "coin_icon", "gem_icon",
            
            // Backgrounds
            "background_gradient", "cloud_1", "cloud_2", "cloud_3"
        ]
        
        let group = DispatchGroup()
        
        for assetName in assetsToLoad {
            group.enter()
            let texture = SKTexture(imageNamed: assetName)
            texture.preload {
                self.textureCache[assetName] = texture
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    // MARK: - Low Memory Handling
    
    func handleLowMemory() {
        print("⚠️ Low memory warning - clearing caches")
        
        // Clear texture cache
        textureCache.removeAll()
        
        // Clear node pools
        nodePool.removeAll()
        
        // Clear action cache
        actionCache.removeAll()
        
        // Force garbage collection
        autoreleasepool {
            // This helps release autoreleased objects
        }
    }
}