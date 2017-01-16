//
//  TagCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/15/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var tagSelectedView: UIView?
    @IBOutlet weak var tagSubtitleLabel: UILabel?
    @IBOutlet weak var tagTitleLabel: UILabel?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        tagSelectedView?.isHidden = !selected
    }
}
