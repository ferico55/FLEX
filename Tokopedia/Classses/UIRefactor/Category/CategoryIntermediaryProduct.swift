//
//  CategoryIntermediaryProduct.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryProduct: NSObject {
    var id: Int = 0
    var departmentId: Int = 0
    var condition: Int = 0
    var imageUrl: String = ""
    var badges: [ProductBadge]!
    var name: String = ""
    var price: String = ""
    var rating: Int = 0
    var url: String = ""
    var wholesalePrice: String = ""
    var labels: [ProductLabel]!
    var shop: CategoryIntermediaryProductShop!
    var applinks: String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryProduct.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "badges", toKeyPath: "badges", with: ProductBadge.mapping()))
         mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "labels", toKeyPath: "labels", with: ProductLabel.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "shop", toKeyPath: "shop", with: CategoryIntermediaryProductShop.mapping()))
        mapping.addAttributeMappings(from:["id", "condition", "name", "price", "rating", "url", "applinks"])
        
        mapping.addAttributeMappings(from:["department_id" : "departmentId",
                                           "image_url" : "imageUrl",
                                           "wholesale_price" : "wholesalePrice",
                                           ])
        return mapping;
    }

}
