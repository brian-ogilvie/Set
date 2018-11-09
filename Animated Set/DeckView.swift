//
//  DeckView.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 5/17/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

@IBDesignable
class DeckView: UIView {
    
    var isVisible = true { didSet{setNeedsDisplay()} }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.cardShadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = Constants.cardShadowRadius
        roundedRect.addClip()
        self.backgroundColor = Colors.backgroundColor
        if isVisible {
            if let cardBackImage = UIImage(named: "maryPoppins", in: Bundle(for: classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    override func layoutSubviews() {
        isOpaque = false
    }

}
extension DeckView {
    private struct Constants {
        static let cardShadowOpacity: Float = 0.2
        static let cardShadowRadius: CGFloat = 3
    }
    private struct Colors {
        static let backgroundColor: UIColor = UIColor(white: 1, alpha: 0)
    }
}

extension DeckView {
    private struct SizeRatios {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.05
        static let shapeWidthToBoundsWidth: CGFloat = 0.75
        static let shapeHeightToBoundsHeight: CGFloat = 0.15
        static let yOffsetFor2ToBoundsHeight: CGFloat = 0.13
        static let yOffsetFor3ToBoundsHeight: CGFloat = 0.2
        static let outlineWidthToBoundsHeight: CGFloat = 0.01
        static let fillLineWidthToBoundsWidth: CGFloat = 0.01
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatios.cornerRadiusToBoundsHeight
    }
}
