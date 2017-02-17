//
//  ProductEditResult.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProductEditResult: NSObject {
    var info: ProductEditInfo = ProductEditInfo()
    var product_images: [ProductEditImages] = []
    var product: ProductEditDetail = ProductEditDetail()
    var server_id: String = ""
    var shop_is_gold: String = ""
    var wholesale_price: [WholesalePrice] = []
    var breadcrumb: [Breadcrumb] = []
    var catalog = CatalogList()
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:[
            "server_id" : "server_id",
            "shop_is_gold" : "shop_is_gold"
        ])
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "info", toKeyPath: "info", with: ProductEditInfo.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "product_images", toKeyPath: "product_images", with: ProductEditImages.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "product", toKeyPath: "product", with: ProductEditDetail.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "wholesale_price", toKeyPath: "wholesale_price", with: WholesalePrice.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "breadcrumb", toKeyPath: "breadcrumb", with: Breadcrumb.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "catalog", toKeyPath: "catalog", with: CatalogList.mapping()))
        
        return mapping
    }
}
