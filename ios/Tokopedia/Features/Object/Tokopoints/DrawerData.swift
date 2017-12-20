//
//  DrawerData.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class DrawerData : NSObject {
    let offFlag: String
    let hasNotification: String
    let mainpageUrl: String
    let userTier: UserTier
    let popUpNotification: PopUpNotification
    
    init(offFlag: String, hasNotification: String, mainpageUrl: String, userTier: UserTier, popUpNotification: PopUpNotification) {
        self.offFlag = offFlag
        self.hasNotification = hasNotification
        self.mainpageUrl = mainpageUrl
        self.userTier = userTier
        self.popUpNotification = popUpNotification
    }
}

extension DrawerData : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> DrawerData {
        let json = JSON(source)
        
        let data = json["data"]
        
        let offFlag = data["off_flag"].stringValue
        let hasNotification = data["has_notif"].stringValue
        let mainpageUrl = data["mainpage_url"].stringValue
        let userTier = UserTier.fromJSON(data["user_tier"].dictionaryValue)
        let popUpNotification = PopUpNotification.fromJSON(data["pop_up_notif"].dictionaryValue)
        
        return DrawerData(offFlag: offFlag, hasNotification: hasNotification, mainpageUrl: mainpageUrl, userTier: userTier, popUpNotification: popUpNotification)
    }
}
