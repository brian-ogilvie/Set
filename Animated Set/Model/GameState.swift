//
//  GameState.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 6/14/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct GameState: Codable {
    var gameComplete: Bool
    
    var baseScore: Int
    var timePoints: Int
    
    var deck: SetDeck
    var visibleCards: [SetCard]
    var matchedCards: [SetCard]
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(complete: Bool, base: Int, time: Int, deck: SetDeck, visible: [SetCard], matched: [SetCard]) {
        self.gameComplete = complete
        self.baseScore = base
        self.timePoints = time
        self.deck = deck
        self.visibleCards = visible
        self.matchedCards = matched
    }
    
    init?(json: Data) {
        if let jsonData = try? JSONDecoder().decode(GameState.self, from: json) {
            self = jsonData
        } else {
            return nil
        }
    }
}
