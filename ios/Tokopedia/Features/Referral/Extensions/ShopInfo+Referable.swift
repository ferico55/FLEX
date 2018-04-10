//
//  ShopInfo+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension ShopInfo: Referable {    
    internal var desktopUrl: String {
        return self.shop_url
    }
    internal var deeplinkPath: String {
        return "shop/" + self.shop_id
    }
    internal var feature: String {
        return "Shop"
    }
    internal var title: String {
        return self.shop_name + " - " + self.shop_location + " | Tokopedia "
    }
    internal var buoDescription: String {
        return self.shop_description
    }
    internal var utmCampaign: String {
        return "shop"
    }
}
