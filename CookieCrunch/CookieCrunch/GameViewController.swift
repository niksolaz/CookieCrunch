//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Nicola Solazzo on 07/02/18.
//  Copyright © 2018 Nicola Solazzo. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    
    var level: Level!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //Call istance Level
        level = Level(filename: "Levels/Level_1")
        scene.level = level
        scene.addTiles()
        
        scene.swipeHandler = handleSwipe
        
        // Present the scene.
        skView.presentScene(scene)
        
        beginGame()
        
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        view.isUserInteractionEnabled = false
        
        level.performSwap(swap: swap)
        
        scene.animate(swap, completion: {
            self.view.isUserInteractionEnabled = true
        })
    }
    
}
