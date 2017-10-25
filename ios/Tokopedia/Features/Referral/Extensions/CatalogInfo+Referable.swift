//
//  CatalogInfo+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension CatalogInfo: Referable {    
    var desktopUrl: String {
        return self.catalog_url
    }
    var deeplinkPath: String {
        return "catalog/" + self.catalog_id + "/" + self.catalog_key
    }
    var feature: String {
        return "Catalog"
    }
    var title: String {
        return self.catalog_name
    }
    var buoDescription: String {
        return self.catalog_description
    }
    var utm_campaign: String {
        return "catalog"
    }
}
