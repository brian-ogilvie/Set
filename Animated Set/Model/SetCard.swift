//
//  SetCard.swift
//  Set Game
//
//  Created by Brian Ogilvie on 4/27/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct SetCard: CustomStringConvertible, Equatable, Codable {
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        if lhs.color.rawValue == rhs.color.rawValue &&
            lhs.number.rawValue == rhs.number.rawValue &&
            lhs.fill.rawValue == rhs.fill.rawValue &&
            lhs.shape.rawValue == rhs.shape.rawValue {
            return true
        } else {return false}
    }
    
    let color: Variant // red, green, purple
    let number: Variant // 1, 2, 3
    let fill: Variant // full, striped, empty
    let shape: Variant // oval, diamond, squiggle
    
    var description: String {return "\(color)-\(number)-\(fill)-\(shape)"}
    
    enum Variant: Int, CustomStringConvertible, Codable {
        case v1 = 1
        case v2
        case v3
        
        static var all:[Variant] {return [.v1, .v2, .v3]}
        var description: String {return String(self.rawValue)}
    }
    
    static func isSet(cards: [SetCard]) -> Bool {
        guard cards.count == 3 else {return false}
//        return true
        let sum = [
            cards.reduce(0, {$0 + $1.color.rawValue}),
            cards.reduce(0, {$0 + $1.number.rawValue}),
            cards.reduce(0, {$0 + $1.fill.rawValue}),
            cards.reduce(0, {$0 + $1.shape.rawValue})
        ]
        return sum.reduce(true, {$0 && ($1 % 3 == 0) })
    }
    
}
