//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Nicola Solazzo on 07/02/18.
//  Copyright © 2018 Nicola Solazzo. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation


class GameViewController: UIViewController {
    
    var scene: GameScene!
    var level: Level!
    // Properties for scoring
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // Display the game over banner
    @IBOutlet weak var gameOverPanel: UIImageView!
    // Give the user an ability to re-shuffle the board
    @IBOutlet weak var shuffleButton: UIButton!
    // Action for when the user clicks the shuffle button
    @IBAction func shuffleButtonPressed(_ sender: Any) {
        shuffle()
        decrementMoves()
    }
    
    // Will detect game over and re-start
    var tapGestureRecognizer: UITapGestureRecognizer!
    // Lazy loaded property for audio
    lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
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
        
        // Hide the game over imageview
        gameOverPanel.isHidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        backgroundMusic?.play()
        beginGame()
        
    }
    
    func beginGame() {
        movesLeft = maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame() {
            self.shuffleButton.isHidden = false
        }
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
        scene.removeAllCookieSprites()
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap: swap)
            scene.animate(swap, completion: handleMatches) 
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(for: chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns: columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
        decrementMoves()
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        if score >= targetScore {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    
    @objc func showGameOver() {
        gameOverPanel.isHidden = false
        scene.isUserInteractionEnabled = false
        
        shuffleButton.isHidden = true
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @objc func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.isHidden = true
        scene.isUserInteractionEnabled = true
        
        beginGame()
    }
    
}
