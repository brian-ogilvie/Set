//
//  CardAreaView.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 5/14/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class CardAreaView: UIView, UIDynamicAnimatorDelegate {
        
    var cardViews = [SetCardView]() { didSet {setNeedsDisplay(); setNeedsLayout() }}
    private lazy var gridCellCount = cardViews.count
    var deckLocation = CGRect()
    private var tempCards = [SetCardView]()
    var displayDiscardPile = false
    
    var hideDeckAfterNextDeal = false    
    
    private var grid = Grid(layout: Grid.Layout.aspectRatio(Constants.gridAspectRatio), frame: CGRect())
        
    func removeSubviews(removedSubviews: [SetCardView]) {
        removedSubviews.forEach { (setCardView) in
            cardViews.remove(elements: [setCardView])
            setCardView.removeFromSuperview()
        }
    }
    
    func flyCards(cardViewsToFly: [SetCardView]) {
        for cardView in cardViewsToFly {
            cardView.modelIdentifier = ""
            cardView.alpha = 0
            tempCards.append(cardView.copyCard())
            cardView.removeFromSuperview()
       }
        for cardView in tempCards {
            self.addSubview(cardView)
            cardBehavior.addItem(item: cardView)
        }
        layoutCardViews()
    }
        
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        displayDiscardPile = true
        tempCards.forEach { tempCard in
            UIView.transition(
                with: tempCard,
                duration: Constants.flipDuration,
                options: [.transitionFlipFromLeft],
                animations: { tempCard.isFaceUp = false},
                completion: {finished in
                    tempCard.removeFromSuperview()
                    self.tempCards.remove(elements: [tempCard])
                }
            )
        }
    }
    
    func animateLeftovers() {
        for item in cardViews {
            UIView.animate(
                withDuration: Constants.leftoverCardFade,
                animations: {
                    item.alpha = 0
                },
                completion: { finished in
                    self.removeSubviews(removedSubviews: [item])
            })
        }
    }
    
    private func layoutCardViews() {
        var delayIndex = 0
        for index in cardViews.indices {
            if cardViews[index].frame == CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0) {
                animateDeal(cardView: cardViews[index], delayMultiplier: delayIndex)
                delayIndex += 1
            }
            animateShift(cardView: cardViews[index], delayMultiplier: 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        grid = Grid(layout: Grid.Layout.aspectRatio(Constants.gridAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        layoutCardViews()
    }
    
    //MARK: Dynamic Animator
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    lazy var cardBehavior: CardBehavior = {
        let behavior = CardBehavior(in: animator)
        return behavior
    }()

    private func animateDeal(cardView: SetCardView, delayMultiplier: Int) {
        cardView.frame = deckLocation
        cardView.alpha = 1 //eventually animate this before dealing
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.dealDuration,
            delay: Constants.dealTimeBetweenCards * Double(delayMultiplier),
            options: [.curveEaseInOut],
            animations: { cardView.frame = self.grid[self.cardViews.index(of: cardView)!]!.insetBy(dx: Constants.gridInsetByDx, dy: Constants.gridInsetByDy) },
            completion: { finished in self.flipCard(cardView: cardView)}
        )
        
    }
    private func animateShift(cardView: SetCardView, delayMultiplier: Int) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.shiftDuration,
            delay: Constants.dealTimeBetweenCards * Double(delayMultiplier),
            options: [.curveEaseInOut],
            animations: { cardView.frame = self.grid[self.cardViews.index(of: cardView)!]!.insetBy(dx: Constants.gridInsetByDx, dy: Constants.gridInsetByDy) }
        )
    }
    
    private func flipCard(cardView: SetCardView) {
        UIView.transition(with: cardView, duration: Constants.flipDuration, options: [.transitionFlipFromLeft], animations: { cardView.isFaceUp = !cardView.isFaceUp})
    }
}

extension CardAreaView {
    private struct Constants {
        static let gridAspectRatio: CGFloat = 0.62
        static let gridInsetByDx: CGFloat = 3.0
        static let gridInsetByDy: CGFloat = 3.0
        static let deckSize =  CGSize(width: 50.0, height: 80.0)
        
        //Animation constants
        static let dealDuration: TimeInterval = 0.6
        static let dealTimeBetweenCards: TimeInterval = 0.1
        static let flipDuration: TimeInterval = 0.6
        static let shiftDuration: TimeInterval = 0.75
        static let timeBeforeDeletingLeftovers: TimeInterval = 3
        static let leftoverCardFade: TimeInterval = 1
    }
}

extension Int {
    func returnTheGreaterOf(a: Int, b: Int) -> Int {
        if a > b {return a}
        else {return b}
    }
}
