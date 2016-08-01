//
//  AddressBookCell.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AddressBookCell: UITableViewCell {

    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var contactName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
