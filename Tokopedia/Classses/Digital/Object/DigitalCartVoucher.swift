//
//  DigitalCartVoucher.swift
//  Tokopedia
//
//  Created by Ronald on 3/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class DigitalCartVoucher:NSObject {
    var voucherCode = ""
    var userId = ""
    var discount = ""
    var discountAmount:Double = 0
    var cashback = ""
    var cashbackAmount:Double = 0
    var total = ""
    var totalAmount:Double = 0
    var message = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["voucher_code":"voucherCode", "user_id":"userId", "discount_amount":"discount", "discount_amount_plain":"discountAmount", "cashback_amount":"cashback", "cashback_amount_plain":"cashbackAmount", "discounted_price":"total", "discounted_price_plain":"totalAmount", "message":"message"])
        return mapping
    }
}
