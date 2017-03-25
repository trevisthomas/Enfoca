//
//  WordPairCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class WordPairCell: UITableViewCell {

    @IBOutlet weak var wordLabelConstraint: NSLayoutConstraint! {
        didSet{
            origWordConstant = wordLabelConstraint.constant
        }
    }
    @IBOutlet weak var definitionLabelConstraint: NSLayoutConstraint! {
        didSet{
            origDefinitionConstant = definitionLabelConstraint.constant
        }
    }
    
    var origWordConstant : CGFloat!
    var origDefinitionConstant : CGFloat!
    
    var wordPair : WordPair! {
        didSet{
            //For some of my unit test these arent wired up.
            guard wordLabel != nil else {
                return
            }
            
            if let score = wordPair.metaData?.scoreAsString {
                definitionLabel.text = "\(wordPair.definition) (\(score))"
            } else {
                definitionLabel.text = wordPair.definition
            }
            
            wordLabel.text = wordPair.word
            
            if wordPair.tags.isEmpty {
                tagLabel.isHidden = true
                tagLabel.text = nil
            } else {
                tagLabel.isHidden = false
                tagLabel.text = "Tags: \(wordPair.tags.tagsToText())"
            }
        }
    }
    var reverseWordPair : Bool!
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    func clear(){
        definitionLabel?.text = nil
        wordLabel?.text = nil
        tagLabel?.text = nil
//        activityIndicator?.startAnimating()
    }
    
//    func animate(){
//        guard let _ = wordLabelConstraint else {
//            return //Some unit tests call this before we're wired
//        }
//        
//        self.contentView.layoutIfNeeded()
//        if self.reverseWordPair == true {
//            self.definitionLabelConstraint.constant = self.origWordConstant
//            self.wordLabelConstraint.constant = self.origDefinitionConstant
//        } else {
//            self.definitionLabelConstraint.constant = self.origDefinitionConstant
//            self.wordLabelConstraint.constant = self.origWordConstant
//        }
//        
//        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
//            self.contentView.layoutIfNeeded()
//        }, completion: nil)
//
//    }
    
    func updateContentPositions(animate : Bool = false) {
        guard let _ = wordLabelConstraint else {
            return //Some unit tests call this before we're wired
        }
        
        self.contentView.layoutIfNeeded()
        if self.reverseWordPair == true {
            self.definitionLabelConstraint.constant = self.origWordConstant
            self.wordLabelConstraint.constant = self.origDefinitionConstant
        } else {
            self.definitionLabelConstraint.constant = self.origDefinitionConstant
            self.wordLabelConstraint.constant = self.origWordConstant
        }
        if animate {
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
                self.contentView.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            self.contentView.layoutIfNeeded()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
