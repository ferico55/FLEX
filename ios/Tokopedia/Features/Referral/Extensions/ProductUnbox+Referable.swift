//
//  ProductUnbox+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension ProductUnbox: Referable {
    var desktopUrl: String {
        return self.url
    }
    var deeplinkPath: String {
        return "product/" + self.id
    }
    var feature: String {
        return "Product"
    }
    var title: String {
        return self.name + " - " + self.shop.name + " | Tokopedia "
    }
    var buoDescription: String {
        return self.info.description
    }
    var utm_campaign: String {
        return "product"
    }
}
