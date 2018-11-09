//
//  CardBehavior.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 5/16/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    var cardAreaViewWidth = CGFloat()
    var discardPileSize = CGSize()
    
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()

    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 1
        behavior.resistance = 0
        behavior.friction = 0
        behavior.angularResistance = 0
        return behavior
    }()
    
    var snapPoint = CGPoint(x: 0, y: 0)
    
    private func snap(item: UIDynamicItem) {
        let snap = UISnapBehavior(item: item, snapTo: snapPoint)
        snap.damping = DynamicAnimationConstants.snapDamping
        self.addChildBehavior(snap)
    }
    
     func push(item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2 * CGFloat.pi).arc4random
//        push.magnitude = DynamicAnimationConstants.pushMagnitudeMultiplier * cardAreaViewWidth
        push.magnitude = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 10
        push.action = { [weak self, unowned push] in
            self?.removeChildBehavior(push)
        }
        self.addChildBehavior(push)
    }
    
    func addItem(item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        Timer.scheduledTimer(withTimeInterval: DynamicAnimationConstants.timeBeforeSnap, repeats: false) { (timer) in
            self.collisionBehavior.removeItem(item)
            self.snap(item: item)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: DynamicAnimationConstants.shrinkDuration,
                delay: 0,
                animations: {
                    if let item = item as? SetCardView {
                        item.bounds.size = self.discardPileSize
                    }
                }
            )

        }
        push(item: item)
    }
    func removeItem(item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(itemBehavior)
        addChildBehavior(collisionBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

extension CardBehavior {
    private struct DynamicAnimationConstants {
        static var pushMagnitudeMultiplier: CGFloat = 0.05
        static let timeBeforeSnap: TimeInterval = 0.75
        static let snapDamping: CGFloat = 2
        static let shrinkDuration: TimeInterval = 0.5
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
