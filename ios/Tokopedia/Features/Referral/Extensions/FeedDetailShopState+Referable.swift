//
//  FeedDetailShopState+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension FeedDetailShopState: Referable {
    internal var desktopUrl: String {
        return self.shareURL
    }
    internal var deeplinkPath: String {
        var subpath = "feedcommunicationdetail/"
        if let url = URL(string: self.shareURL) {
            subpath += url.lastPathComponent
        }
        return subpath
    }
    internal var feature: String {
        return "Feed"
    }
    internal var title: String {
        return self.shareDescription
    }
    internal var buoDescription: String {
        return ""
    }
    internal var utmCampaign: String {
        return "feed"
    }
}
