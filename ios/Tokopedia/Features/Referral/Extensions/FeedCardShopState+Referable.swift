//
//  FeedCardShopState+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension FeedCardShopState: Referable {
    var desktopUrl: String {
        return self.shareURL
    }
    var deeplinkPath: String {
        var subpath = "feedcommunicationdetail/"
        if let url = URL(string: self.shareURL) {
            subpath += url.lastPathComponent
        }
        return subpath
    }
    var feature: String {
        return "Feed"
    }
    var title: String {
        return self.shareDescription
    }
    var buoDescription: String {
        return ""
    }
    var utm_campaign: String {
        return "feed"
    }
}
