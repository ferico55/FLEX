//
//  CatalogInfo+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension CatalogInfo: Referable {    
    internal var desktopUrl: String {
        return self.catalog_url
    }
    internal var deeplinkPath: String {
        return "catalog/" + self.catalog_id + "/" + self.catalog_key
    }
    internal var feature: String {
        return "Catalog"
    }
    internal var title: String {
        return self.catalog_name
    }
    internal var buoDescription: String {
        return self.catalog_description
    }
    internal var utmCampaign: String {
        return "catalog"
    }
}
