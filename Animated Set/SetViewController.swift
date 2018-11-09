//
//  SetViewController.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 5/14/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    var player: Player?
    
    @IBOutlet weak var cardAreaView: CardAreaView! {
        didSet {
//            let rotationGestureRecognizer = UIRotationGestureRecognizer(
//                target: self, action: #selector(shuffleCards(recognizer:))
//            )
//            cardAreaView.addGestureRecognizer(rotationGestureRecognizer)
        }
    }
    
    @IBOutlet weak var endGameLbl: UILabel!
    
//    @objc func shuffleCards(recognizer: UIRotationGestureRecognizer) {
//        switch recognizer.state {
//        case .ended:
//            print("Rotation gesture ended.")
//            game.shuffleVisibleCards()
//        default:
//            break
//        }
//    }

    
    @objc private func deal(recognizer: UITapGestureRecognizer) {
        game.draw3Cards()
    }

    @IBOutlet weak var dealButton: DeckView!
    @IBOutlet weak var dealLabel: UILabel!
    
    @IBAction func newGame(_ sender: UIButton? = nil) {
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.gameComplete.rawValue)
        player?.numberOfGamesPlayed += 1
        cardAreaView.removeSubviews(removedSubviews: cardAreaView.cardViews)
        dealButton.isVisible = true
        dealLabel.isHidden = false
        discardPile.isVisible = false
        endGameLbl.isHidden = true
        game = SetGame()
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    
    @IBAction func giveHint(_ sender: UIButton) {
        game.giveHint()
    }
    
    
    @IBOutlet weak var discardPile: DeckView!
    
    private var game = SetGame() {
        didSet{
            updateViewFromModel()
            updateDocument()
        }
    }
    
    private var gameState: GameState? {
        get {
           return game.gameState
        }
        set {
            if let newValue = newValue {
                game.gameState = newValue
                updateViewFromModel()
            }
        }
    }
    
    private var dealButtonOrigin: CGPoint {
        return view.convert(dealButton.superview!.frame.origin, to: cardAreaView)
    }
    private var discardPileCenter: CGPoint {
        let stackViewOrigin = discardPile.superview!.frame.origin
        let newCenter = CGPoint(x: stackViewOrigin.x + discardPile.center.x, y: stackViewOrigin.y + discardPile.center.y)
        return view.convert(newCenter, to: cardAreaView)
    }
    
    @objc private func touchCard(recognizer: UITapGestureRecognizer) {
        if let cardView = recognizer.view! as? SetCardView {
            game.touchCard(cardIndex: cardAreaView.cardViews.index(of: cardView)!)
        }
    }
        
    func displayEndGame() {
        let finalScore = game.getTotalScore(forPlayer: 0)
        var endGameMessage = "The game has ended!\n"
        endGameMessage += "Score: \(finalScore)"
        if let oldHighScore = player?.highScore {
            if finalScore > oldHighScore {
                endGameMessage += "\nNew High Score!"
            }
        }
        player?.mostRecentScore = finalScore
        player?.updateHighScore()
        endGameLbl.text = endGameMessage
        endGameLbl.alpha = 0
        endGameLbl.isHidden = false
        UIView.animate(
            withDuration: AnimationConstants.endGameLblVisible,
            animations: {
                self.endGameLbl.alpha = 1
        })
        cardAreaView.animateLeftovers()
    }
    
    //MARK: updateViewFromModel()
    private func updateViewFromModel() {
        cardAreaView.deckLocation = CGRect(
            x: dealButtonOrigin.x,
            y: dealButtonOrigin.y,
            width: dealButton.frame.width,
            height: dealButton.frame.height
        )
        scoreLabel.text = "Score: \(game.getTotalScore(forPlayer: 0))"
        if game.gameComplete {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.gameComplete.rawValue)
            displayEndGame()
            return
        }
        updateCardViews()
    }
    
    private let cardViewColors = ["red","green","purple"]
    private let cardViewFills = ["full","empty","striped"]
    private let cardViewShapes = ["oval","diamond","squiggle"]

    private func updateCardView(cardView: SetCardView, as gameCard: SetCard) -> SetCardView {
        if cardView.modelIdentifier != gameCard.description {
            cardView.modelIdentifier = gameCard.description
            cardView.color = cardViewColors[gameCard.color.rawValue-1]
            cardView.fill = cardViewFills[gameCard.fill.rawValue-1]
            cardView.shape = cardViewShapes[gameCard.shape.rawValue-1]
            cardView.number = gameCard.number.rawValue
            cardView.alpha = 0
        }
        cardView.isSelected = game.selectedCards.contains(gameCard)
        cardView.isMatched = game.matchedCards.contains(gameCard)
        if cardView.isSelected && !cardView.isMatched && game.selectedCards.count == 3 {
            cardView.isMismatched = true
        } else {
            cardView.isMismatched = false
        }
        cardView.isHinted = game.shownHint.contains(gameCard)
        return cardView
    }
    
    private func drawSelection(cardView: SetCardView) {
        cardView.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor

        if cardView.isSelected {
            if cardView.isMatched {
                cardView.layer.borderColor = Colors.matchedStrokeColor
            }
            else if cardView.isMismatched {
                cardView.layer.borderColor = Colors.mismatchedStrokeColor
            }
            else {
                cardView.layer.borderColor = Colors.selectedStrokeColor
            }
        }
        else if cardView.isHinted {
            cardView.layer.borderColor = Colors.hintedStrokeColor
        }
    }
    
    private func updateCardViews() {
        var newCardViews = [SetCardView]()
        var cardsToRemove = [SetCardView]()
        var matchedModelCardIdentifiers = [String]()
        var visibleCardsModelCardIdentifiers = [String]()
        
        for gameCard in game.matchedCards {
            matchedModelCardIdentifiers.append(gameCard.description)
        }
        for gameCard in game.visibleCards {
            visibleCardsModelCardIdentifiers.append(gameCard.description)
        }
        guard viewHasAppeared else { return }

        for index in game.visibleCards.indices {
            let gameCard = game.visibleCards[index]
            if cardAreaView.cardViews.contains(where: { (cardView) -> Bool in
                cardView.modelIdentifier == gameCard.description
            }) { // if card is already on the screen
                let cardViewIndex = cardAreaView.cardViews.index(where: { (cardView) -> Bool in
                    cardView.modelIdentifier == gameCard.description
                })
                cardAreaView.cardViews[cardViewIndex!] = updateCardView(cardView: cardAreaView.cardViews[cardViewIndex!], as: gameCard)
                drawSelection(cardView: cardAreaView.cardViews[cardViewIndex!])
            } else {
                var cardView = SetCardView()
                cardView = updateCardView(cardView: cardView, as: gameCard)
                addTapGestureRecognizer(to: cardView)
                    newCardViews.append(cardView)
            }
        }
        for cardView in cardAreaView.cardViews {
            if matchedModelCardIdentifiers.contains(cardView.modelIdentifier) {
                cardView.isSelected = false
                drawSelection(cardView: cardView)
                cardsToRemove.append(cardView)
                if cardsToRemove.count == 3 {
                    cardAreaView.flyCards(cardViewsToFly: cardsToRemove)
                    cardsToRemove = []
                    Timer.scheduledTimer(withTimeInterval: AnimationConstants.timeBeforeAutoDeal, repeats: false) { (timer) in
                        self.updateViewFromModel()
                    }
                    return
                }
            }
        }

        if newCardViews.count > 0 {
            if game.deckCount == 0 {
                dealButton.isVisible = false
                dealLabel.isHidden = true
            }
            discardPile.isVisible = game.matchedCards.count > 0
            for cardView in newCardViews {
                if let cardViewIndex = cardAreaView.cardViews.index(where: { (cardView) -> Bool in
                    cardView.modelIdentifier == ""
                }) { // if cards are being replaced
                    cardAreaView.cardViews[cardViewIndex] = cardView
                }
                else { // if cards are being added at end
                    cardAreaView.cardViews.append(cardView)
                }
                cardAreaView.addSubview(cardView)
            }
        }
        else if cardAreaView.cardViews.count > game.visibleCards.count {//remove empty spaces
            cardAreaView.cardViews.remove(elements: cardAreaView.cardViews.filter({ (cardView) -> Bool in
                cardView.modelIdentifier == ""
            }))
        }
        
    }
    private func addDealTapGestureRecognizer(to button: DeckView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deal(recognizer:)))
        button.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func addTapGestureRecognizer(to cardView: SetCardView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchCard(recognizer:)))
        cardView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private var blinkTimer = Timer()
    
    private func showBonusPoints(_ points: Int) {
        bonusLabel.text = "Bonus +\(String(describing: points))"
        bonusLabel.sizeToFit()
        let startCenter = self.view.center
        bonusLabel.center = startCenter
        var blinks = 0
        blinkTimer = Timer.scheduledTimer(withTimeInterval: AnimationConstants.blinkInterval, repeats: true) { (timer) in
            self.bonusLabel.isHidden = !self.bonusLabel.isHidden
            blinks += 1
            if blinks == AnimationConstants.numberOfBlinks { //must be an odd number or label will be hidden
                timer.invalidate()
                UIView.animate(
                    withDuration: AnimationConstants.springWindupDuration,
                    delay: AnimationConstants.springWindupDelay,
                    animations: {
                    self.bonusLabel.center.y += AnimationConstants.springWindupDistance
                }, completion: { (finished) in
                    if finished {
                        UIView.animate(
                            withDuration: AnimationConstants.bonusFlyOutDuration,
                            delay: AnimationConstants.bonusFlyOutDelay,
                            usingSpringWithDamping: AnimationConstants.bonusFlyOutDamping,
                            initialSpringVelocity: AnimationConstants.bonusFlyOutVelo,
                            options: [],
                            animations: {
                                self.bonusLabel.center.y = self.view.bounds.minY - self.bonusLabel.frame.height
                        }, completion: { (finished) in
                            self.bonusLabel.isHidden = true
                            self.bonusLabel.center = startCenter
                        })
                    }
                })
            }
        }
    }
    
    //MARK: - VCLC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAppLifeCycleObservers()
        addDealTapGestureRecognizer(to: dealButton)
        discardPile.isVisible = false
        if player?.numberOfGamesPlayed == 0 {
            player?.numberOfGamesPlayed += 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        cardAreaView.cardBehavior.snapPoint = discardPileCenter
        cardAreaView.cardBehavior.cardAreaViewWidth = cardAreaView.bounds.width
        cardAreaView.cardBehavior.discardPileSize = discardPile.bounds.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        openDocument()
        
        bonusPointsObserver = NotificationCenter.default.addObserver(
            forName: .BonusPointsAdded,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] (notification) in
                if let userInfo = notification.userInfo {
                    if let points = userInfo["points"] as? Int {
                        self?.showBonusPoints(points)
                    }
                }
            }
        )
    }
    
    private var bonusPointsObserver: NSObjectProtocol?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
        updateViewFromModel()
    }
    var viewHasAppeared = false
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.mostRecentScore = game.getTotalScore(forPlayer: 0)
        player?.updateHighScore()
        UserDefaults.standard.synchronize()
        if let observer = bonusPointsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        updateDocument()
        document?.updateChangeCount(.done)
        closeDocument()
    }
    
    //MARK: - Application Life Cycle
    private func addAppLifeCycleObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(closeDocument),
            name: Notification.Name.UIApplicationDidEnterBackground,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openDocument),
            name: Notification.Name.UIApplicationWillEnterForeground,
            object: nil)
    }
    
    //MARK: - UIDocument
    var document: SetGameStateDocument?
    
    @objc private func openDocument() {
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ).appendingPathComponent("Untitled.json") {
            document = SetGameStateDocument(fileURL: url)
            document?.open(completionHandler: { [weak self] (success) in
                if success {
                    self?.gameState = self?.document?.gameState
                } else {
                    if let jsonData = self?.gameState?.json {
                        try? jsonData.write(to: url)
                        self?.openDocument()
                        return
                    }
                }
            })
        }
    }
    
    private func updateDocument() {
        document?.gameState = gameState
        document?.updateChangeCount(.done)
    }
    
    @objc private func closeDocument() {
        document?.updateChangeCount(.done)
        document?.close()
    }
}

extension SetViewController {
    private struct Colors {
        static let defaultStrokeColor: CGColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor
        static let matchedStrokeColor: CGColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        static let mismatchedStrokeColor: CGColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        static let selectedStrokeColor: CGColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        static let hintedStrokeColor: CGColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
    
    private struct AnimationConstants {
        static let timeBeforeAutoDeal: TimeInterval = 1.5
        static let endGameLblVisible: TimeInterval = 2
        static let blinkInterval: TimeInterval = 0.08
        static let numberOfBlinks: Int = 7
        static let springWindupDuration: TimeInterval = 0.3
        static let springWindupDelay: TimeInterval = 1.5
        static let springWindupDistance: CGFloat = 10
        static let bonusFlyOutDuration: TimeInterval = 1
        static let bonusFlyOutDelay: TimeInterval = 0
        static let bonusFlyOutDamping: CGFloat = 0.5
        static let bonusFlyOutVelo: CGFloat = 0
    }
}

