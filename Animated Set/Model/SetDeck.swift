//
//  SetDeck.swift
//  Set Game
//
//  Created by Brian Ogilvie on 4/27/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct SetDeck: Codable {
    private(set) var cards = [SetCard]()
    
    init() {
        for number in SetCard.Variant.all {
            for color in SetCard.Variant.all {
                for fill in SetCard.Variant.all {
                    for shape in SetCard.Variant.all {
                        cards.append(SetCard(color: color, number: number, fill: fill, shape: shape /*SetCard.Variant.v3*/))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        guard cards.count > 0 else {return nil}
        return cards.remove(at: cards.count.arc4random)
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }
        else if self < 0 {
            return Int(arc4random_uniform(UInt32(abs(self))))
        }
        else {return 0}
    }
}
