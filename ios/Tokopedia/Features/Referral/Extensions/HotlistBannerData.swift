//
//  HotlistBannerData.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
internal class HotlistBannerData: NSObject, Referable {
    internal var desktopUrl = ""
    internal var deeplinkPath = ""
    internal var feature = "Hotlist"
    internal var title = ""
    internal var buoDescription: String {
        return ""
    }
    internal var utmCampaign = "hotlist"
}
