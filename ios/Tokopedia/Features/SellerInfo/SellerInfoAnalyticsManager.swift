//
//  SellerInfoAnalyticsManager.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 02/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    static func trackSellerInfoArticleClick(article: String) {
        let manager = AnalyticsManager()
        let data = [
            "event": "clickSellerInfo",
            "eventCategory": "seller info-homepage",
            "eventAction": "click article",
            "eventLabel": article,
            ]
        manager.dataLayer.push(data)
    }
    
    static func trackSellerInfoMenuClick() {
        let manager = AnalyticsManager()
        let data = [
            "event": "clickSellerInfo",
            "eventCategory": "seller info-homepage",
            "eventAction": "click hamburger icon",
            "eventLabel": "seller info",
            ]
        manager.dataLayer.push(data)
    }
}

