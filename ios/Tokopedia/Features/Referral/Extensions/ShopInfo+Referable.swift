//
//  ShopInfo+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension ShopInfo: Referable {    
    var desktopUrl: String {
        return self.shop_url
    }
    var deeplinkPath: String {
        return "shop/" + self.shop_id
    }
    var feature: String {
        return "Shop"
    }
    var title: String {
        return self.shop_name + " - " + self.shop_location + " | Tokopedia "
    }
    var buoDescription: String {
        return self.shop_description
    }
    var utm_campaign: String {
        return "shop"
    }
}
