//
//  AutoCode.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 3/28/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

public final class AutoCode:NSObject {
    public var success = false
    public var code = ""
    public var isCoupon = false
    public var discountAmount:Double = 0
    public var title = ""
    public var message = ""
    public var id = 0
    public var discount = ""
    public var totalAmount:Double = 0
    public var total = ""
    
    public override init() {
        super.init()
    }
    
    public init(success:Bool, code: String, isCoupon: Bool, discountAmount: Double, title: String, message:String, id: Int, discount: String, totalAmount: Double, total: String) {
        self.success = success
        self.code = code
        self.isCoupon = isCoupon
        self.discountAmount = discountAmount
        self.title = title
        self.message = message
        self.id = id
        self.discount = discount
        self.totalAmount = totalAmount
        self.total = total
    }
    
    public class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "success": "success",
            "code": "code",
            "is_coupon": "isCoupon",
            "discount_amount": "discountAmount",
            "title_description": "title",
            "message_success": "message",
            "promo_id": "id"
            ])
        
        return mapping!
    }
}

extension AutoCode: Unboxable {
    public convenience init(unboxer:Unboxer) throws {
        let success = try unboxer.unbox(keyPath: "success") as Bool
        let code = try unboxer.unbox(keyPath: "code") as String
        let isCoupon = try unboxer.unbox(keyPath: "is_coupon") as Bool
        let discountAmount = try unboxer.unbox(keyPath: "discount_amount") as Double
        let title = try unboxer.unbox(keyPath: "title_description") as String
        let message = try unboxer.unbox(keyPath: "message_success") as String
        let id = try unboxer.unbox(keyPath: "promo_id") as Int
        let discount = try unboxer.unbox(keyPath: "discount_price") as String
        let totalAmount = try unboxer.unbox(keyPath: "discounted_amount") as Double
        let total = try unboxer.unbox(keyPath: "discounted_price") as String
        
        self.init(success:success, code: code, isCoupon: isCoupon, discountAmount: discountAmount, title: title, message:message, id: id, discount: discount, totalAmount: totalAmount, total: total)
    }
}
