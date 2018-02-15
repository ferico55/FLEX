//
//  ComplaintTableViewCell.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 06/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class ComplaintTableViewCell: UITableViewCell {

    // MARK: outlets
    @IBOutlet internal weak var lblStatus: UILabel!
    @IBOutlet internal weak var lblSubject: UILabel!
    @IBOutlet internal weak var isReadIndicator: UIView!
    @IBOutlet internal weak var lblAuthorType: UILabel!
    @IBOutlet internal weak var lblName: UILabel!
    @IBOutlet internal weak var lblExpiry: UILabel!
    @IBOutlet internal weak var lblNoExpiry: UILabel!
    @IBOutlet internal weak var lblLastReplied: UILabel!
    @IBOutlet internal weak var lblFreeReturn: UILabel!
    @IBOutlet internal weak var imgProduct1: UIImageView!
    @IBOutlet internal weak var imgProduct2: UIImageView!
    @IBOutlet internal weak var imgProduct3: UIImageView!
    @IBOutlet internal weak var lblMoreProducts: UILabel!
    @IBOutlet internal weak var lblSeeMore: UILabel!
    @IBOutlet internal weak var noImageConstraint: NSLayoutConstraint!
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        
        lblSeeMore.layer.shadowColor = UIColor.tpBorder().cgColor
        lblSeeMore.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        lblSeeMore.layer.shadowRadius = 2.0
        lblSeeMore.layer.shadowOpacity = 1.0
        lblSeeMore.layer.masksToBounds = false
        
        lblExpiry.layer.cornerRadius = 3
        lblExpiry.layer.masksToBounds = true
        
        imgProduct1.layer.cornerRadius = 3
        imgProduct1.layer.masksToBounds = true
        imgProduct2.layer.cornerRadius = 3
        imgProduct2.layer.masksToBounds = true
        imgProduct3.layer.cornerRadius = 3
        imgProduct3.layer.masksToBounds = true
        
        self.selectionStyle = .none
    }

    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
