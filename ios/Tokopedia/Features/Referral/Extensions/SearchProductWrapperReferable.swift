//
//  SearchProductWrapperReferable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
class SearchProductWrapperReferable:NSObject, Referable {
    var wrapper: SearchProductWrapper?
    var desktopUrl: String {
        let desktopUrl = (self.wrapper?.data.shareUrl ?? NSString.tokopediaUrl())
        return desktopUrl
    }
    var deeplinkPath: String {
        let subpath = "search?" + ((URL(string:self.desktopUrl)?.query) ?? "")
        return subpath
    }
    var feature = "Discovery"
    var title = ""
    var buoDescription: String {
        return ""
    }
    var utm_campaign = "searchResult"
}
