//
//  ProductDetail+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension Product: Referable {    
    var desktopUrl: String {
        return self.data.info.product_url
    }
    var deeplinkPath: String {
        return "product/" + self.data.info.product_id
    }
    var feature: String {
        return "Product"
    }
    var title: String {
        let name = self.data.info.product_name ?? ""
        let shop_name = self.data.shop_info.shop_name ?? ""
        return name + " - " + shop_name + " | Tokopedia "
    }
    var buoDescription: String {
        return self.data.info.product_description
    }
    var utm_campaign: String {
        return "product"
    }
}
