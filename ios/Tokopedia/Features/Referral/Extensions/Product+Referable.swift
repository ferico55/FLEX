//
//  ProductDetail+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension Product: Referable {    
    internal var desktopUrl: String {
        return self.data.info.product_url
    }
    internal var deeplinkPath: String {
        return "product/" + self.data.info.product_id
    }
    internal var feature: String {
        return "Product"
    }
    internal var title: String {
        let name = self.data.info.product_name ?? ""
        let shop_name = self.data.shop_info.shop_name ?? ""
        return name + " - " + shop_name + " | Tokopedia "
    }
    internal var buoDescription: String {
        return self.data.info.product_description
    }
    internal var utmCampaign: String {
        return "product"
    }
}
