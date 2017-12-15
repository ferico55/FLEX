//
//  HotlistPromoInfo.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class HotlistPromoInfo: NSObject {

    var voucherCode = ""
    var promoPeriod = ""
    var text = ""
    var minimalTransaction = ""
    var applinks = ""
    
    var isEmpty: Bool {
        if voucherCode.isEmpty
            && promoPeriod.isEmpty
            && text.isEmpty
            && minimalTransaction.isEmpty
            && applinks.isEmpty {
            return true
        }
        
        return false
    }
    
    class func mapping() -> RKObjectMapping {
        
        let attributeDictionary = [
            "voucher_code" : "voucherCode",
            "promo_period" : "promoPeriod",
            "text" : "text",
            "min_tx" : "minimalTransaction",
            "tc_applink" : "applinks"
        ]
        
        let mapping: RKObjectMapping = RKObjectMapping(for: HotlistPromoInfo.self)
        mapping.addAttributeMappings(from:attributeDictionary)
        return mapping;
    }
}
