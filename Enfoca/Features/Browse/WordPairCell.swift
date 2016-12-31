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
            wordLabel.text = wordPair.word
        }
    }
    var reverseWordPair : Bool!
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
