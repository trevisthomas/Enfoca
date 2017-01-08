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
            wordLabel.text = wordPair.word
            definitionLabel.text = wordPair.definition
            if wordPair.tags.isEmpty {
                tagLabel.isHidden = true
                tagLabel.text = nil
            } else {
                tagLabel.isHidden = false
                tagLabel.text = "Tags: \(wordPair.tags.tagsToText())"
            }
            
            activeSwitch.isOn = wordPair.active
        }
    }
    var reverseWordPair : Bool!
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var tagLabel: UILabel!

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
    
    @IBAction func activeSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            wordPair.active = true
            getAppDelegate().webService.activateWordPair(wordPair : wordPair, callback: { success in
                //Do sometning if the web call fails
            })
        }
        else {
            wordPair.active = false
            getAppDelegate().webService.deactivateWordPair(wordPair : wordPair, callback: { success in
                //Do sometning if the web call fails
            })
        }
    }
}
