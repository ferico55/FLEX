//
//  SellerInfoNotificationData.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 16/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

final class SellerInfoNotificationData: NSObject {
    let notificationUnread: Int
    
    init(notificationUnread: Int) {
        self.notificationUnread = notificationUnread
    }
}

extension SellerInfoNotificationData : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> SellerInfoNotificationData {
        
        let json = JSON(source["data"] ?? [:])
        
        let notificationUnread = json["notification"].intValue
        
        return SellerInfoNotificationData(notificationUnread: notificationUnread)
    }
}
