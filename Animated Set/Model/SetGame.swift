//
//  SetGame.swift
//  Set Game
//
//  Created by Brian Ogilvie on 4/27/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct SetGame {
    private let initialNumberOfCards = 12
    private(set) var gameComplete = false
    
    private(set) var player1Index = 0
    private(set) var player2Index = 1
    var activePlayerIndex: Int? = 0
    
    private(set) var baseScore = [0,0]
    private var player1Score: Int {return baseScore[player1Index] + totalTimePoints[player1Index]}
    private var player2Score: Int {return baseScore[player2Index] + totalTimePoints[player2Index]}
    func getTotalScore(forPlayer playerIndex: Int) -> Int {
        let score = baseScore[playerIndex] + totalTimePoints[playerIndex]
        return score
    }
//    enum Points: Int {
//        case match = 10
//        case mismatch = -8
//        case drawPenalty = -3
//        case askForHint = -5
//    }
    
    private(set) var totalTimePoints = [0,0]
    var timeBonusPoints = 0 {
        didSet {
            if timeBonusPoints > 0 {
                NotificationCenter.default.post(name: .BonusPointsAdded, object: self, userInfo: ["points": timeBonusPoints])
            }
        }
    }
    private let timeBonusInterval: TimeInterval = 10

    private var lastSuccessfulMove = [Date(),Date()]
    
    private(set) var deck = SetDeck()
    var deckCount: Int {return deck.cards.count}
    private(set) var visibleCards = [SetCard]()
    private(set) var selectedCards = [SetCard]()
    private(set) var matchedCards = [SetCard]()
    private(set) var hints = [[SetCard]]()
    private(set) var shownHint = [SetCard]()
    
    mutating func touchCard(cardIndex: Int) {
        guard activePlayerIndex != nil else {return}
        guard cardIndex < visibleCards.count else {return}
        guard !gameComplete else {return}
        let card = visibleCards[cardIndex]
        shownHint = []
        
        //If 3 cards are already selected
        if selectedCards.count == 3 {//These three cards aren't a set
            selectedCards = []
            lookForSets()
            return
        }
        //continue selecting or deselecting
        if selectedCards.count < 3 {
            selectedCards.insertOrRemove(element: card)
        }
        // if three cards are just now selected
        if selectedCards.count == 3 {
            
            if SetCard.isSet(cards: selectedCards) {
                matchedCards.append(contentsOf: selectedCards)
                
                //It's a set! Add points
                baseScore[activePlayerIndex!] += Scoring.match
                timeBonusPoints = timeBonus()
                if timeBonusPoints > 0 {
                    totalTimePoints[activePlayerIndex!] += timeBonusPoints
                }
                lastSuccessfulMove[activePlayerIndex!] = Date()
                // game over when no more possible sets and no cards left in deck
                hints = []
                if deckCount >= 3 {
                    visibleCards.replace(elements: selectedCards, withNew: take3FromDeck(), atEnd: false)
                }
                else {
                    visibleCards.remove(elements: selectedCards)
                }
                selectedCards = []
                lookForSets()
                if hints.count == 0 && deckCount == 0 || visibleCards.count == 0 {
                    gameComplete = true
                }
            }
            else {
                //It's not a set. Take points away
                baseScore[activePlayerIndex!] += Scoring.mismatch
                //Don't allow next successful move to get a time bonus
                lastSuccessfulMove[activePlayerIndex!] -= timeBonusInterval
            }
        }
    }
        
    private mutating func timeBonus() -> Int {
        guard activePlayerIndex != nil else {return 0}
        let timeBetween = DateInterval(start: lastSuccessfulMove[activePlayerIndex!], end: Date()).duration
        var timeScoreAdjustment = 0
        if timeBetween < timeBonusInterval {
            timeScoreAdjustment = Scoring.timeBonus
        }
        return timeScoreAdjustment
    }
    
    mutating func draw3Cards() {
        guard activePlayerIndex != nil || hints.count == 0 else {return}
        guard deckCount >= 3 else {return}
        if hints.count > 0 {
            baseScore[activePlayerIndex!] += Scoring.drawPenalty
        }
        visibleCards.append(contentsOf: take3FromDeck())
        lookForSets()
    }
    
    private mutating func take3FromDeck() -> [SetCard] {
        guard deckCount >= 3 else {return []}
        var newCards = [SetCard]()
        for _ in 1...3 {
            if let newCard = deck.draw() {
                newCards.append(newCard)
            }
        }
        return newCards
    }
    
    private mutating func lookForSets() {
        guard visibleCards.count >= 3 else {return}
        hints = []
        var tryCards = [SetCard]()
        for i in 0..<visibleCards.count-2 {
            for ii in i+1..<visibleCards.count-1 {
                for iii in ii+1..<visibleCards.count {
                    tryCards = [visibleCards[i],visibleCards[ii], visibleCards[iii]]
                    if SetCard.isSet(cards: tryCards) {
                        hints.append(tryCards)
                    }
                }
            }
        }
        if hints.isEmpty && deckCount > 0 {
            draw3Cards()
        }
    }
    
    mutating func giveHint() {
        if selectedCards.count == 3 {
            return
        }
        selectedCards = []
        if hints.count > 0 {
            baseScore[player1Index] += Scoring.hintPenalty
            shownHint = hints[hints.count.arc4random]
        }
        else {
            return
        }
    }
    
    mutating func shuffleVisibleCards() {
        var randomArray = [SetCard]()
        while visibleCards.count > 0 {
            randomArray.append(visibleCards.remove(at: visibleCards.count.arc4random))
        }
        visibleCards = randomArray
    }
    
    
    init() {
        for _ in 1...initialNumberOfCards {
            if let newCard = deck.draw() {
                visibleCards.append(newCard)
            }
        }
        lookForSets()
    }
}

extension SetGame {
    var gameState: GameState {
        get {
            let gameState = GameState(complete: gameComplete, base: baseScore[0], time: totalTimePoints[0], deck: deck, visible: visibleCards, matched: matchedCards)
            return gameState
        }
        set {
            self.gameComplete = newValue.gameComplete
            self.baseScore[0] = newValue.baseScore
            self.totalTimePoints[0] = newValue.timePoints
            self.deck = newValue.deck
            self.visibleCards = newValue.visibleCards
            self.matchedCards = newValue.matchedCards
            lookForSets()
        }
    }
}

extension Array where Element: Equatable {
    mutating func insertOrRemove(element: Element) {
        if let from = self.index(of: element) {
            remove(at: from)
        }
        else {
            append(element)
        }
    }
    
    mutating func remove(elements: [Element]) {
        self = self.filter {!elements.contains($0)}
    }
    
    func contains(array: [Element]) -> Bool {
        return array.reduce(true, {$0 && (self.contains($1))})
    }
    
    mutating func replace(elements: [Element], withNew: [Element], atEnd: Bool) {
        guard elements.count == withNew.count else {return}
        for index in 0..<withNew.count {
            if let foundIndex = self.index(of: elements[index]) {
                self.remove(at: foundIndex)
                if !atEnd {
                    self.insert(withNew[index], at: foundIndex)
                }
                else {
                    self.append(withNew[index])
                }
            }
        }
    }
}
extension Notification.Name {
    static let BonusPointsAdded = Notification.Name("BonusPointsAdded")
}
struct Scoring {
    static let match = 10
    static let mismatch = -8
    static let timeBonus = 5
    static let drawPenalty = -3
    static let hintPenalty = -5
}
