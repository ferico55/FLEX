//
//  DigitalVoucher.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class DigitalVoucher:Unboxable {
    var voucherCode = ""
    var userId = ""
    var discount = ""
    var discountAmount:Double = 0
    var cashback = ""
    var cashbackAmount:Double = 0
    var total = ""
    var totalAmount:Double = 0
    var message = ""
    
    init(voucherCode:String = "", userId:String = "", discount:String = "", discountAmount:Double = 0.0, cashback:String = "", cashbackAmount:Double = 0.0, total:String = "", totalAmount:Double = 0.0, message:String = "") {
        self.voucherCode = voucherCode
        self.userId = userId
        self.discount = discount
        self.discountAmount = discountAmount
        self.cashback = cashback
        self.cashbackAmount = cashbackAmount
        self.total = total
        self.totalAmount = totalAmount
        self.message = message
    }
    
    convenience init(unboxer: Unboxer) throws {
        let voucherCode = try unboxer.unbox(keyPath: "data.attributes.voucher_code") as String
        let userId = try unboxer.unbox(keyPath: "data.attributes.user_id") as String
        let discount = try unboxer.unbox(keyPath: "data.attributes.discount_amount") as String
        let discountAmount = try unboxer.unbox(keyPath: "data.attributes.discount_amount_plain") as Double
        let cashback = try unboxer.unbox(keyPath: "data.attributes.cashback_amount") as String
        let cashbackAmount = try unboxer.unbox(keyPath: "data.attributes.cashback_amount_plain") as Double
        let total = try unboxer.unbox(keyPath: "data.attributes.discounted_price") as String
        let totalAmount = try unboxer.unbox(keyPath: "data.attributes.discounted_price_plain") as Double
        let message = try unboxer.unbox(keyPath: "data.attributes.message") as String
        
        self.init(voucherCode:voucherCode, userId:userId, discount:discount, discountAmount:discountAmount, cashback:cashback, cashbackAmount:cashbackAmount, total:total, totalAmount:totalAmount, message:message)
    }
}
