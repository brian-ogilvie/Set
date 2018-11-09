//
//  Player.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 6/13/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct Player {
    var numberOfGamesPlayed: Int { didSet { UserDefaults.standard.set(numberOfGamesPlayed, forKey: UserDefaultsKeys.gamesPlayed.rawValue) } }
    var highScore: Int { didSet { UserDefaults.standard.set(highScore, forKey: UserDefaultsKeys.highScore.rawValue) } }
    var mostRecentScore: Int { didSet { UserDefaults.standard.set(mostRecentScore, forKey: UserDefaultsKeys.lastScore.rawValue) } }
    var gameComplete: Bool { didSet {UserDefaults.standard.set(gameComplete, forKey: UserDefaultsKeys.gameComplete.rawValue)} }
    
    mutating func updateHighScore() {
        if mostRecentScore > highScore {
            highScore = mostRecentScore
        }
    }
    
    init (gamesPlayed: Int, highScore: Int, lastScore: Int, gameComplete: Bool) {
        self.numberOfGamesPlayed = gamesPlayed
        self.highScore = highScore
        self.mostRecentScore = lastScore
        self.gameComplete = gameComplete
    }
}
