//
//  InstructionsViewController.swift
//  Animated Set
//
//  Created by Brian Ogilvie on 6/17/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstParagraph: UILabel! {
        didSet {
            firstParagraph.text = "Set is a real-time card game designed by Marsha Falco in 1974 and published by Set Enterprises in 1991. The deck consists of 81 cards varying in four features: number (one, two, or three); symbol (diamond, squiggle, oval); shading (solid, striped, or open); and color (red, green, or purple). Each possible combination of features (e.g., a card with three striped green diamonds) appears precisely once in the deck."
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
        }
    }
    
    @IBOutlet weak var matchLbl: UILabel! {didSet{matchLbl.text = "+\(String(describing: Scoring.match))"}}
    @IBOutlet weak var timeBonusLbl: UILabel! {didSet{timeBonusLbl.text = "+\(String(describing: Scoring.timeBonus))"}}
    @IBOutlet weak var mismatchLbl: UILabel! {didSet{mismatchLbl.text = "\(String(describing: Scoring.mismatch))"}}
    @IBOutlet weak var drawPenaltyLbl: UILabel! {didSet{drawPenaltyLbl.text = "\(String(describing: Scoring.drawPenalty))"}}
    @IBOutlet weak var hintPenaltyLbl: UILabel! {didSet{hintPenaltyLbl.text = "\(String(describing: Scoring.hintPenalty))"}}

    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
