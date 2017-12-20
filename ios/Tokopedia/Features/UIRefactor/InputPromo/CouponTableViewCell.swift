//
//  CouponTableViewCell.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CouponTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var iconExpiredImgView: UIImageView!
    @IBOutlet weak var lblExpireIn: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
