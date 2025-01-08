//
//  ScoreView.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/15/21.
//

import UIKit

@IBDesignable
class ScoreView: UIView {
    
    @IBOutlet weak var scoreTitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        
        scoreTitleLabel.underline()
    }
    
    func loadView() {
        TCModel.scoreUpdateClosure = {
            self.scoreLabel.text = String(TCModel.currentScore)
        }
        TCModel.loadScore()
    }
    
}
