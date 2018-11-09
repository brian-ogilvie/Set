//
//  SetCardView.swift
//  Graphical Set
//
//  Created by Brian Ogilvie on 5/7/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    @IBInspectable
    var modelIdentifier: String = "0000"
    @IBInspectable
    var shape: String = "oval"
    @IBInspectable
    var number: Int = 1
    @IBInspectable
    var fill: String = "empty"
    @IBInspectable
    var color: String = "black"
    @IBInspectable
    var isFaceUp: Bool = false { didSet{setNeedsLayout();setNeedsDisplay()}}
    
    lazy var descriptionString: String = {
        return "\(self.number) \(self.fill) \(self.color) \(self.shape) \(self.isSelected)"
    }()
    
    private var shapePath = UIBezierPath()
    
    private var shapeColor: CGColor {
        switch color {
        case "red":
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case "green":
            return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        case "purple":
            return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        default:
            print("color \"\(color)\" is not a valid value.")
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var isSelected = false
    var isMatched = false
    var isMismatched = false
    var isHinted = false
        
    //draw the squiggle shape
    private func drawSquiggle(centerY: CGFloat) {
        let squigglePath = UIBezierPath()
        squigglePath.move(to: CGPoint(x: bounds.midX - shapeDX, y: centerY))
        squigglePath.addCurve(to: CGPoint(x: bounds.midX + shapeDX, y: centerY), controlPoint1: CGPoint(x: bounds.midX, y: centerY - controlPoint1YOffset), controlPoint2: CGPoint(x: bounds.midX, y: centerY + controlPoint2YOffset))
        squigglePath.addCurve(to: CGPoint(x: bounds.midX - shapeDX, y: centerY), controlPoint1: CGPoint(x: bounds.midX, y: centerY + controlPoint1YOffset), controlPoint2: CGPoint(x: bounds.midX, y: centerY - controlPoint2YOffset))
        shapePath.append(squigglePath)
    }
    
    // draw the oval shape
    private func drawOval(centerY: CGFloat) {
        let oval = UIBezierPath(roundedRect: CGRect(x: bounds.midX-shapeDX, y: centerY-shapeDY, width: shapeDX*2, height: shapeDY*2), cornerRadius: shapeDY)
        shapePath.append(oval)
    }
    
    // draw the diamond shape
    private func drawDiamond(centerY: CGFloat) {
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: bounds.midX - shapeDX, y: centerY))
        diamond.addLine(to: CGPoint(x: bounds.midX, y: centerY - shapeDY))
        diamond.addLine(to: CGPoint(x: bounds.midX + shapeDX, y: centerY))
        diamond.addLine(to: CGPoint(x: bounds.midX, y: centerY + shapeDY))
        diamond.close()
        shapePath.append(diamond)
    }
    
    // draw the lines for the "striped" fill
    private func drawLines() {
        let numberOfLines = Constants.numberOfLines
        let dX = shapeDX/(CGFloat(numberOfLines/2))
        for line in 0..<numberOfLines {
            let xPoint = bounds.midX - shapeDX + dX*CGFloat(line)
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: xPoint, y: bounds.minY))
            linePath.addLine(to: CGPoint(x: xPoint, y: bounds.maxY))
            linePath.lineWidth = bounds.width * SizeRatios.fillLineWidthToBoundsWidth
            linePath.stroke()
            
        }
    }
    
    // chose which shape function to use
    private func chooseShape(yOffset: CGFloat) -> () {
        switch shape {
        case "oval":
            return drawOval(centerY: yOffset)
        case "diamond":
            return drawDiamond(centerY: yOffset)
        case "squiggle":
            return drawSquiggle(centerY: yOffset)
        default:
            print("shape \"\(shape)\" is not a valid value.")
            return ()
        }
    }
    
    // execute the path creation using all the card variables
    private func drawAndPlace() {
        if isFaceUp {
            switch number {
            case 1: chooseShape(yOffset: bounds.midY)
            case 2: chooseShape(yOffset: bounds.midY - yOffsetFor2)
            chooseShape(yOffset: bounds.midY + yOffsetFor2)
            case 3: chooseShape(yOffset: bounds.midY - yOffsetFor3)
            chooseShape(yOffset: bounds.midY)
            chooseShape(yOffset: bounds.midY + yOffsetFor3)
            default: print("number \"\(number)\" is an invalid value.")
            }
            UIColor.init(cgColor: shapeColor).set()
            shapePath.lineWidth = outlineWidth
            shapePath.stroke()
            shapePath.addClip()
            if fill == "striped" {
                drawLines()
            }
            else if fill == "full" {
                shapePath.fill()
            }
            else if fill == "empty" {
                //do nothing
            }
            else {
                print("fill \"\(fill)\" is not a valid value.")
            }
        } else {
            if let cardBackImage = UIImage(named: "maryPoppins", in: Bundle(for: classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.layoutIfNeeded()
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = cardBorderWidth
        layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.cardShadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = Constants.cardShadowRadius
        roundedRect.addClip()
        UIColor.init(cgColor: Colors.cardFrontBGColor).setFill()
        roundedRect.fill()
        
        drawAndPlace()
    }
    
    override func layoutSubviews() {
        super.layoutIfNeeded()
        isOpaque = false
    }
}

extension SetCardView {
    private struct Constants {
        static let numberOfLines: Int = 15
        static let cardShadowOpacity: Float = 0.2
        static let cardShadowRadius: CGFloat = 3
    }
}

extension SetCardView {
    private struct Colors {
        static let cardBackBGColor: CGColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        static let cardFrontBGColor: CGColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
}

extension SetCardView {
    private struct SizeRatios {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.05
        static let shapeWidthToBoundsWidth: CGFloat = 0.75
        static let shapeHeightToBoundsHeight: CGFloat = 0.15
        static let yOffsetFor2ToBoundsHeight: CGFloat = 0.13
        static let yOffsetFor3ToBoundsHeight: CGFloat = 0.2
        static let outlineWidthToBoundsHeight: CGFloat = 0.01
        static let cardBorderWidthToBoundsWitdh: CGFloat = 0.04
        static let fillLineWidthToBoundsWidth: CGFloat = 0.01
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatios.cornerRadiusToBoundsHeight
    }
    private var shapeDX: CGFloat {
        return SizeRatios.shapeWidthToBoundsWidth * bounds.width/2
    }
    private var shapeDY: CGFloat {
        return SizeRatios.shapeHeightToBoundsHeight * bounds.height/2
    }
    private var controlPoint1YOffset: CGFloat {
        return shapeDY * 2.5
    }
    private var controlPoint2YOffset: CGFloat {
        return shapeDY * 0.9
    }
    private var yOffsetFor2: CGFloat {
        return bounds.height * SizeRatios.yOffsetFor2ToBoundsHeight
    }
    private var yOffsetFor3: CGFloat {
        return bounds.height * SizeRatios.yOffsetFor3ToBoundsHeight
    }
    private var outlineWidth: CGFloat {
        return bounds.height * SizeRatios.outlineWidthToBoundsHeight
    }
    private var cardBorderWidth: CGFloat {
        return bounds.width * SizeRatios.cardBorderWidthToBoundsWitdh
    }
}
extension SetCardView {
    func copyCard() -> SetCardView {
        let newCard = SetCardView()
        newCard.shape = self.shape
        newCard.color = self.color
        newCard.fill = self.fill
        newCard.number = self.number
        newCard.isFaceUp = self.isFaceUp
        newCard.isMatched = true
        newCard.frame = self.frame
        return newCard
    }
}
