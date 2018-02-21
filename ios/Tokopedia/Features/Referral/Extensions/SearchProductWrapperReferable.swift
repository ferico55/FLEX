//
//  SearchProductWrapperReferable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
internal class SearchProductWrapperReferable:NSObject, Referable {
    internal var shareUrl: String?
    internal var desktopUrl: String {
        let desktopUrl = (self.shareUrl?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? NSString.tokopediaUrl())
        return desktopUrl
    }
    internal var deeplinkPath: String {
        var subpath = "search"
        if var query = URL(string:self.desktopUrl)?.query {
            if query.hasPrefix("&") {
                query.remove(at: query.startIndex)
            }
            subpath += "?" + query
        }
        return subpath
    }
    internal var feature = "Discovery"
    internal var title = ""
    internal var buoDescription: String {
        return ""
    }
    internal var utmCampaign = "searchResult"
}
