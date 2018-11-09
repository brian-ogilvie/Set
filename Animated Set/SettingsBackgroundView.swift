//
//  SettingsBackgroundView.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 6/13/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class SettingsBackgroundView: UIView {
    private var deck = SetDeck()
    private let numberOfCards = 8
    private var cardsToUse = [SetCard]()
    private var cardViews = [SetCardView]()
    
    private var firstAnimationComplete = false
    
    private let cardViewColors = ["red","green","purple"]
    private let cardViewFills = ["full","empty","striped"]
    private let cardViewShapes = ["oval","diamond","squiggle"]

    func showCards() {
        guard !firstAnimationComplete else {return}
        subviews.forEach { $0.removeFromSuperview() }
        for _ in 1...numberOfCards {
            cardsToUse.append(deck.draw()!)
        }
        for card in cardsToUse {
            let cardView = SetCardView()
            cardView.color = cardViewColors[card.color.rawValue-1]
            cardView.fill = cardViewFills[card.fill.rawValue-1]
            cardView.number = card.number.rawValue
            cardView.shape = cardViewShapes[card.shape.rawValue-1]
            cardView.isFaceUp = true
            cardViews.append(cardView)
            cardView.frame = CGRect(x: cardViewStartX, y: cardViewStartY, width: cardViewWidth, height: cardViewHeight)
            self.addSubview(cardView)
        }
        animateCardSpill()
    }
    func animateCardSpill() {
        guard !cardViews.isEmpty else {return}
        var duration: TimeInterval = 0.4
        var rotationAngle = Constants.firstCardRotationAngle
        for cardView in cardViews {
            cardView.frame.origin = CGPoint(x: cardViewStartX, y: cardViewStartY)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                let endX = self.cardViewEndX + CGFloat(self.cardViews.index(of: cardView)!) * self.xDistance
                let endY = self.cardViewStartY + CGFloat(self.cardViews.index(of: cardView)!) * self.yDistance
                cardView.frame.origin = CGPoint(x: endX, y: endY)
                cardView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }, completion: {success in
                if self.cardViews.index(of: cardView) == self.cardViews.count - 1 {
                    self.firstAnimationComplete = true
                }
            })
            duration += 0.1
            rotationAngle += rotationInterval
        }
    }
}
extension SettingsBackgroundView {
    private struct Constants {
        static let cardViewAspectRatio: CGFloat = 5/8
        static let cardViewHeightToBoundsHeight: CGFloat = 1
        static let firstCardRotationAngle: CGFloat = CGFloat.pi * 0.15
    }
    private var rotationInterval: CGFloat {
        return (CGFloat.pi * 0.5 - Constants.firstCardRotationAngle)/CGFloat(numberOfCards - 1)
    }
    private var cardViewHeight: CGFloat {
        return Constants.cardViewHeightToBoundsHeight * bounds.height
    }
    private var cardViewWidth: CGFloat {
        return cardViewHeight * Constants.cardViewAspectRatio
    }
    private var cardViewStartX: CGFloat {
        return bounds.minX - cardViewWidth
    }
    private var cardViewEndX: CGFloat {
        return bounds.minX
    }
    private var xDistance: CGFloat {
        return bounds.width / CGFloat(numberOfCards + 1)
    }
    private var cardViewStartY: CGFloat {
        return bounds.minY
    }
    private var cardViewEndY: CGFloat {
        return bounds.maxY - bounds.height * 0.3
    }
    private var yDistance: CGFloat {
        return (cardViewEndY - cardViewStartY) / CGFloat(numberOfCards)
    }
}
