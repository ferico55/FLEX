//
//  HotlistBannerResult+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension HotlistBannerResult: Referable {    
    internal var desktopUrl: String {
        let title = (self.info.alias_key ?? "")
        return NSString.tokopediaUrl() + "/hot/" + title
    }
    internal var deeplinkPath: String {
        let title = (self.info.alias_key ?? "")
        return "hot/" + title
    }
    internal var feature: String {
        return "Hotlist"
    }
    internal var title: String {
        return "Jual " +  self.info.title + " | Tokopedia "
    }
    internal var buoDescription: String {
        return self.info.hotlist_description
    }
    internal var utmCampaign: String {
        return "hotlist"
    }
}
