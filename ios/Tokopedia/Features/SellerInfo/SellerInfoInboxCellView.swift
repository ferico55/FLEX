//
//  SellerInfoInboxCellView.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 04/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

class SellerInfoInboxCellView: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorInset = .zero
        self.layoutMargins = .zero
        self.preservesSuperviewLayoutMargins = false
    }
    
    func isReadMode(_ isRead: Bool) {
        self.contentView.backgroundColor = isRead ? UIColor.white : UIColor(red: 243.0/255.0, green: 254.0/255.0, blue:224.0/255.0, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
