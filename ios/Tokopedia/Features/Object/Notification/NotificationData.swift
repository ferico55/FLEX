//
//  NotificationData.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

final class NotificationData: NSObject, NSCoding {
    var totalNotif: Int
    let totalCart: Int
    var incrNotif: Int
    let resolution: Int
    var sellerInfoNotif: Int
    var inbox: NotificationInbox?
    let sales: NotificationSales?
    let purchase: NotificationPurchase?
    
    init(
        totalNotif: Int,
        totalCart: Int,
        incrNotif: Int,
        resolution: Int,
        sellerInfoNotif: Int,
        inbox: NotificationInbox?,
        sales: NotificationSales?,
        purchase: NotificationPurchase?
        ) {
        self.totalNotif = totalNotif
        self.totalCart = totalCart
        self.incrNotif = incrNotif
        self.resolution = resolution
        self.sellerInfoNotif = sellerInfoNotif
        self.inbox = inbox
        self.sales = sales
        self.purchase = purchase
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let inbox = decoder.decodeObject(forKey: "inbox") as? NotificationInbox,
            let sales = decoder.decodeObject(forKey: "sales") as? NotificationSales,
            let purchase = decoder.decodeObject(forKey: "purchase") as? NotificationPurchase
            else { return nil }
        
        self.init(
            totalNotif: decoder.decodeInteger(forKey: "totalNotif"),
            totalCart: decoder.decodeInteger(forKey: "totalCart"),
            incrNotif: decoder.decodeInteger(forKey: "incrNotif"),
            resolution: decoder.decodeInteger(forKey: "resolution"),
            sellerInfoNotif: decoder.decodeInteger(forKey: "sellerInfoNotif"),
            inbox: inbox,
            sales: sales,
            purchase: purchase
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.totalNotif, forKey: "totalNotif")
        aCoder.encode(self.totalCart, forKey: "totalCart")
        aCoder.encode(self.incrNotif, forKey: "incrNotif")
        aCoder.encode(self.resolution, forKey: "resolution")
        aCoder.encode(self.sellerInfoNotif, forKey: "sellerInfoNotif")
        aCoder.encode(self.inbox, forKey: "inbox")
        aCoder.encode(self.sales, forKey: "sales")
        aCoder.encode(self.purchase, forKey: "purchase")
    }
}

extension NotificationData : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> NotificationData {
        
        let json = JSON(source["data"] ?? [:])
        
        let totalNotif = json["total_notif"].intValue
        let totalCart = json["total_cart"].intValue
        let incrNotif = json["incr_notif"].intValue
        let resolution = json["resolution"].intValue
        let inbox = NotificationInbox.fromJSON(json["inbox"].dictionaryObject ?? [:])
        let sales = NotificationSales.fromJSON(json["sales"].dictionaryObject ?? [:])
        let purchase = NotificationPurchase.fromJSON(json["purchase"].dictionaryObject ?? [:])
        
        // set seller info notif to 0 here, cause it's grabbed from another endpoint
        return NotificationData(totalNotif: totalNotif, totalCart: totalCart, incrNotif: incrNotif, resolution: resolution, sellerInfoNotif: 0, inbox: inbox, sales: sales, purchase: purchase)
    }
}
