//
//  PulsaProductCell.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaProductCell: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var promoPrice: UILabel!
    @IBOutlet weak var productStatus: UILabel!
    @IBOutlet weak var productTag: UILabel!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
