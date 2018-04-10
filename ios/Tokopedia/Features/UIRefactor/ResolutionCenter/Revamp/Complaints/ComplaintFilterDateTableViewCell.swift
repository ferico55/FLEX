//
//  ComplaintFilterDateTableViewCell.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 07/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class ComplaintFilterDateTableViewCell: UITableViewCell {

    // MARK: outlets
    @IBOutlet internal weak var lblDateIdentifier: UILabel!
    @IBOutlet internal weak var lblDate: UILabel!
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
    }

    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
