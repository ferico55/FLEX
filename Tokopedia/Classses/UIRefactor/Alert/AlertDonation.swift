//
//  AlertDonation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/14/17.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(AlertDonation) class AlertDonation: TKPDAlertView {
    
    @IBOutlet fileprivate var alertTitleLabel: UILabel!
    @IBOutlet fileprivate var alertMessageLabel: UILabel!
    @IBOutlet fileprivate var alertImage: UIImageView!
    
    init(title:String, info:String, imageUrlString:String) {
        super.init(frame: .zero)
        
        alertTitleLabel.text = title
        alertMessageLabel.text = info
        alertImage.setImageWithUrl(URL(string: imageUrlString)!, placeHolderImage: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
