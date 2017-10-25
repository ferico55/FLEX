//
//  HotlistBannerResult+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension HotlistBannerResult: Referable {    
    var desktopUrl: String {
        let title = (self.info.alias_key ?? "")
        return NSString.tokopediaUrl() + "/hot/" + title
    }
    var deeplinkPath: String {
        let title = (self.info.alias_key ?? "")
        return "hot/" + title
    }
    var feature: String {
        return "Hotlist"
    }
    var title: String {
        return "Jual " +  self.info.title + " | Tokopedia "
    }
    var buoDescription: String {
        return self.info.hotlist_description
    }
    var utm_campaign: String {
        return "hotlist"
    }
}
