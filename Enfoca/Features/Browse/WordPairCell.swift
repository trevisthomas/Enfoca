//
//  WordPairCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class WordPairCell: UITableViewCell {

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
//        {
//        didSet{
//            if reverseWordPair == true {
//                backgroundColor = UIColor.green
//            } else {
//                backgroundColor = UIColor.white
//            }
//        }
//    }
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
