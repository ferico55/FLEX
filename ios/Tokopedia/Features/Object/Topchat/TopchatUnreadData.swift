//
//  TopchatUnreadData.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

final class TopchatUnreadData: NSObject {
    let notificationUnread: Int
    
    init(notificationUnread: Int) {
        self.notificationUnread = notificationUnread
    }
}

extension TopchatUnreadData : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> TopchatUnreadData {
        
        let json = JSON(source["data"] ?? [:])
        
        let notificationUnread = json["notif_unreads"].intValue
        
        return TopchatUnreadData(notificationUnread: notificationUnread)
    }
}
