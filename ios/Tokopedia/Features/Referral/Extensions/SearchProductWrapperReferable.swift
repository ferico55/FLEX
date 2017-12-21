//
//  SearchProductWrapperReferable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
class SearchProductWrapperReferable:NSObject, Referable {
    var shareUrl: String?
    var desktopUrl: String {
        let desktopUrl = (self.shareUrl?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? NSString.tokopediaUrl())
        return desktopUrl
    }
    var deeplinkPath: String {
        var subpath = "search"
        if var query = URL(string:self.desktopUrl)?.query {
            if query.hasPrefix("&") {
                query.remove(at: query.startIndex)
            }
            subpath += "?" + query
        }
        return subpath
    }
    var feature = "Discovery"
    var title = ""
    var buoDescription: String {
        return ""
    }
    var utm_campaign = "searchResult"
}
