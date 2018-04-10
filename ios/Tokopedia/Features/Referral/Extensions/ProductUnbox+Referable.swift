//
//  ProductUnbox+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension ProductUnbox: Referable {
    internal var desktopUrl: String {
        return self.url
    }
    internal var deeplinkPath: String {
        return "product/" + self.id
    }
    internal var feature: String {
        return "Product"
    }
    internal var title: String {
        return self.name + " - " + self.shop.name + " | Tokopedia "
    }
    internal var buoDescription: String {
        return self.info.descriptionHtml()
    }
    internal var utmCampaign: String {
        return "product"
    }
}
