//
//  NotificationSales.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

final class NotificationSales: NSObject, NSCoding {
    var newOrder: Int
    let shippingStatus: Int
    var shippingConfirm: Int
    
    init(
        newOrder: Int,
        shippingStatus: Int,
        shippingConfirm: Int
        ) {
        self.newOrder = newOrder
        self.shippingStatus = shippingStatus
        self.shippingConfirm = shippingConfirm
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init(
            newOrder: decoder.decodeInteger(forKey: "newOrder"),
            shippingStatus: decoder.decodeInteger(forKey: "shippingStatus"),
            shippingConfirm: decoder.decodeInteger(forKey: "shippingConfirm")
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.newOrder, forKey: "newOrder")
        aCoder.encode(self.shippingStatus, forKey: "shippingStatus")
        aCoder.encode(self.shippingConfirm, forKey: "shippingConfirm")
    }
}

extension NotificationSales : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> NotificationSales {
        let json = JSON(source)
        
        let newOrder = json["sales_new_order"].int ?? 0
        let shippingStatus = json["sales_shipping_status"].int ?? 0
        let shippingConfirm = json["sales_shipping_confirm"].int ?? 0
        
        return NotificationSales(newOrder: newOrder, shippingStatus: shippingStatus, shippingConfirm: shippingConfirm)
    }
}
