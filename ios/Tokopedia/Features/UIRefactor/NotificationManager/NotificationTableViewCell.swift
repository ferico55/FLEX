//
//  NotificationTableViewCell.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class NotificationTableViewCell: UITableViewCell {
    @IBOutlet internal weak var lblTitle: UILabel!
    @IBOutlet internal weak var lblCount: UILabel!
    @IBOutlet internal weak var unreadIndicator: UIView!

    internal override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
