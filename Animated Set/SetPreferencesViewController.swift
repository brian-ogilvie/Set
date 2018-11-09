//
//  SetPreferencesViewController.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 6/13/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class SetPreferencesViewController: UIViewController {
    
    //MARK:- UserDefaults
    var player: Player?
    
    private func setPlayer() {
        player = Player(
            gamesPlayed: UserDefaults.standard.object(forKey: UserDefaultsKeys.gamesPlayed.rawValue) as? Int ?? 0,
            highScore: UserDefaults.standard.object(forKey: UserDefaultsKeys.highScore.rawValue) as? Int ?? 0,
            lastScore: UserDefaults.standard.object(forKey: UserDefaultsKeys.lastScore.rawValue) as? Int ?? 0,
            gameComplete: UserDefaults.standard.object(forKey: UserDefaultsKeys.gameComplete.rawValue) as? Bool ?? false
        )
    }
    
    //MARK: - Storyboard
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func newGame(_ sender: UIButton) {
        //Nothing to do but segue
    }
    
    @IBOutlet weak var gamesPlayedLbl: UILabel!
    @IBOutlet weak var highScoreLbl: UILabel!
    @IBOutlet weak var lastScoreLbl: UILabel!
    
    @IBOutlet weak var settingsBackgroundView: SettingsBackgroundView!
    
    @IBOutlet weak var settingsBackgroundViewHeight: NSLayoutConstraint!
    
    //MARK:- VCLC
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPlayer()
        displayStats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        settingsBackgroundView.showCards()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingsBackgroundViewHeight.constant = view.bounds.height * 0.2
    }
    
    private func displayStats() {
        if player != nil {
            gamesPlayedLbl.text = "Games Played: \(String(describing: player!.numberOfGamesPlayed))"
            highScoreLbl.text = "High Score: \(String(describing: player!.highScore))"
            var scoreText = player!.gameComplete ? "Most Recent Score" : "Current Score"
            scoreText += ": \(String(describing: player!.mostRecentScore))"
            lastScoreLbl.text = scoreText
        }
    }
 
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Play Game" {
                if let setVC = segue.destination as? SetViewController {
                    setVC.player = player
                }
            }
        }
    }
}
