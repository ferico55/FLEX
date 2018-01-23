//
//  SellerInfoInboxFilterCellView.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 04/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

class SellerInfoInboxFilterCellView: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorInset = .zero
        self.layoutMargins = .zero
        self.preservesSuperviewLayoutMargins = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.checkmark.isHidden   = !selected
        self.titleLabel.textColor = selected ? UIColor.tpGreen() : UIColor.tpPrimaryBlackText()
    }
    
}
