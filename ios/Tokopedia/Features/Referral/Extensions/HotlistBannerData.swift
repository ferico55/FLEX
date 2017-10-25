//
//  HotlistBannerData.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
class HotlistBannerData: NSObject, Referable {
    var desktopUrl = ""
    var deeplinkPath = ""
    var feature = "Hotlist"
    var title = ""
    var buoDescription: String {
        return ""
    }
    var utm_campaign = "hotlist"
}
