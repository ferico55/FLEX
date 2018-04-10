//
//  ComplaintInbox.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 02/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit

final internal class ComplaintInbox: NSObject {
    internal let id: String
    internal let resolutionId: String
    internal let status: String
    internal let statusInt: String
    internal let statusFontColorHex: String
    internal let statusBgColorHex: String
    internal let isRead: String
    internal let isResponded: String
    internal let lastReplyTime: String
    internal let autoExecuteTime: String
    internal let autoExecuteTimeColorHex: String
    internal let isFreeReturn: String
    internal let productImageUrls: [String]
    internal let seller: String
    internal let customer: String
    internal let orderNumber: String
    
    internal init(id: String, resolutionId: String, status: String, statusInt: String, statusFontColorHex: String, statusBgColorHex: String, isRead: String, isResponded: String, lastReplyTime: String, autoExecuteTime: String, autoExecuteTimeColorHex: String, isFreeReturn: String, productImageUrls: [String], seller: String, customer: String, orderNumber: String) {
        self.id = id
        self.resolutionId = resolutionId
        self.status = status
        self.statusInt = statusInt
        self.statusFontColorHex = statusFontColorHex
        self.statusBgColorHex = statusBgColorHex
        self.isRead = isRead
        self.isResponded = isResponded
        self.lastReplyTime = lastReplyTime
        self.autoExecuteTime = autoExecuteTime
        self.autoExecuteTimeColorHex = autoExecuteTimeColorHex
        self.isFreeReturn = isFreeReturn
        self.productImageUrls = productImageUrls
        self.seller = seller
        self.customer = customer
        self.orderNumber = orderNumber
    }
}

extension ComplaintInbox : JSONAbleType {
    internal static func fromJSON(_ source: [String: Any]) -> ComplaintInbox {
        let json = JSON(source)
        
        let id = json["id"].stringValue
        let resolutionId = json["resolution"]["id"].stringValue
        let status = json["resolution"]["status"]["string"].stringValue
        let statusInt = json["resolution"]["status"]["int"].stringValue
        let statusFontColorHex = json["resolution"]["status"]["fontColor"].stringValue
        let statusBgColorHex = json["resolution"]["status"]["bgColor"].stringValue
        let isRead = json["resolution"]["read"].stringValue
        let isResponded = json["resolution"]["responded"].stringValue
        let lastReplyTime = json["resolution"]["lastReplyTime"]["fullString"].stringValue
        let autoExecuteTime = json["resolution"]["autoExecuteTime"]["timeLeft"].stringValue
        let autoExecuteTimeColorHex = json["resolution"]["autoExecuteTime"]["color"].stringValue
        let isFreeReturn = json["resolution"]["freeReturn"].stringValue
        let productImageUrls = json["resolution"]["product"].arrayValue.map { (json) -> String in
            return !json["images"].arrayValue.isEmpty ? json["images"].arrayValue[0]["thumb"].stringValue : ""
        }
        let seller = json["shop"]["name"].stringValue
        let customer = json["customer"]["name"].stringValue
        let orderNumber = json["order"]["refNum"].stringValue
        
        return ComplaintInbox(id: id, resolutionId: resolutionId, status: status, statusInt: statusInt, statusFontColorHex: statusFontColorHex, statusBgColorHex: statusBgColorHex, isRead: isRead, isResponded: isResponded, lastReplyTime: lastReplyTime, autoExecuteTime: autoExecuteTime, autoExecuteTimeColorHex: autoExecuteTimeColorHex, isFreeReturn: isFreeReturn, productImageUrls: productImageUrls, seller: seller, customer: customer, orderNumber: orderNumber)
    }
}
