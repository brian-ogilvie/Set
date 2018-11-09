//
//  SetGameStateDocument.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 6/14/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class SetGameStateDocument: UIDocument {
    var gameState: GameState?
    
    override func contents(forType typeName: String) throws -> Any {
        return gameState?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            gameState = GameState(json: json)
        }
    }
}

extension UIDocumentState: CustomStringConvertible {
    public var description: String {
        return [
            UIDocumentState.normal.rawValue:".normal",
            UIDocumentState.closed.rawValue:".closed",
            UIDocumentState.inConflict.rawValue:".inConflict",
            UIDocumentState.savingError.rawValue:".savingError",
            UIDocumentState.editingDisabled.rawValue:".editingDisabled",
            UIDocumentState.progressAvailable.rawValue:".progressAvailable"
            ][rawValue] ?? String(rawValue)
    }
}
