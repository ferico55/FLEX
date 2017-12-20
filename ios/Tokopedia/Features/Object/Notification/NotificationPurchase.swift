//
//  NotificationPurchase.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

final class NotificationPurchase: NSObject, NSCoding {
    let reorder: Int
    var paymentConfirm: Int
    var orderStatus: Int
    var deliveryConfirm: Int
    
    init(
        reorder: Int,
        paymentConfirm: Int,
        orderStatus: Int,
        deliveryConfirm: Int
    ) {
        self.reorder = reorder
        self.paymentConfirm = paymentConfirm
        self.orderStatus = orderStatus
        self.deliveryConfirm = deliveryConfirm
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init(
            reorder: decoder.decodeInteger(forKey: "reorder"),
            paymentConfirm: decoder.decodeInteger(forKey: "paymentConfirm"),
            orderStatus: decoder.decodeInteger(forKey: "orderStatus"),
            deliveryConfirm: decoder.decodeInteger(forKey: "deliveryConfirm")
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.reorder, forKey: "reorder")
        aCoder.encode(self.paymentConfirm, forKey: "paymentConfirm")
        aCoder.encode(self.orderStatus, forKey: "orderStatus")
        aCoder.encode(self.deliveryConfirm, forKey: "deliveryConfirm")
    }
}

extension NotificationPurchase : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> NotificationPurchase {
        let json = JSON(source)
        
        let reorder = json["purchase_reorder"].int ?? 0
        let paymentConfirm = json["purchase_payment_confirm"].int ?? 0
        let orderStatus = json["purchase_order_status"].int ?? 0
        let deliveryConfirm = json["purchase_delivery_confirm"].int ?? 0
        
        return NotificationPurchase(reorder: reorder, paymentConfirm: paymentConfirm, orderStatus: orderStatus, deliveryConfirm: deliveryConfirm)
    }
}
