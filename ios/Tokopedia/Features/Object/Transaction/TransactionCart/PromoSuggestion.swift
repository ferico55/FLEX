//
//  PromoSuggestion.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PromoSuggestion: NSObject {
    
    var text = ""
    var cta = ""
    var ctaColor = ""
    var visible = "0"
    var isVisible: Bool {
        get {
            return visible == "1" && !isUsingVoucher
        }
    }
    var isUsingVoucher = false
    var promoCode = "GRATISONGIR"
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: [
            "text": "text",
            "cta": "cta",
            "cta_color": "ctaColor",
            "is_visible": "visible",
            "promo_code": "promoCode",
            ])
        
        return mapping
    }

}
