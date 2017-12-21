//
//  RCStatusDeliveryInfo.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 24/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit
class RCStatusDeliveryInfo: NSObject {
    var show = false
    var date: Date?
    override init(){}
    init(json:[String:JSON]) {
        if let show = json["show"]?.bool {
            self.show = show
        }
        if let dateString = json["date"]?.string {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale.current
            formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
            self.date = formatter.date(from: dateString)
        }
    }
}
