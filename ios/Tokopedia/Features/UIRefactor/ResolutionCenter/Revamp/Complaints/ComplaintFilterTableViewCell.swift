//
//  ComplaintFilterTableViewCell.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 07/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class ComplaintFilterTableViewCell: UITableViewCell {

    // MARK: outlets
    @IBOutlet internal weak var lblTitle: UILabel!
    @IBOutlet internal weak var imgCheckbox: UIImageView!
    
    internal override var isSelected: Bool {
        didSet {
            imgCheckbox.setImage(isSelected ? #imageLiteral(resourceName: "checkboxselected") : #imageLiteral(resourceName: "checkboxnotselected"), animated: true)
        }
    }
    
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
