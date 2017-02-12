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
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func createButtonAction(_ sender: UIButton) {
        createButton?.isHidden = true
        guard let callback = createTagCallback else {return}
        guard let tagValue = tagTitleLabel?.text else {return}
        callback(self, tagValue)
    }
    
    var createTagCallback : ((TagCell, String)->())? = nil {
        didSet{
            createButton?.isHidden = createTagCallback == nil
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        tagSelectedView?.isHidden = !selected
    }
}
