//
//  Donation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class Donation: NSObject {
    
    var title = ""
    var info = ""
    var popUpTitle = ""
    var popUpInfo = ""
    var popUpImage = ""
    var name = ""
    var value = ""
    var valueIdr = ""
    var isSelected : Bool = false {
        didSet {
            usedDonationValue = isSelected ? value : "0"
        }
    }
    var usedDonationValue = "0"

    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: [
                "donation_note_title"   : "title",
                "donation_note_info"    : "info",
                "donation_popup_title"  : "popUpTitle",
                "donation_popup_info"   : "popUpInfo",
                "donation_popup_image"  : "popUpImage",
                "donation_value"        : "value",
                "donation_value_idr"    : "valueIdr",
                "donation_name"         : "name"
            ])
        
        return mapping
    }

}
