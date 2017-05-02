//
//  CategoryIntermediaryCuratedProduct.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryCuratedProduct: NSObject {
    var categoryId: Int = 0
    var sections: [CategoryIntermediaryCuratedProductSection]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryCuratedProduct.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "sections", toKeyPath: "sections", with: CategoryIntermediaryCuratedProductSection.mapping()))
        mapping.addAttributeMappings(from:["category_id" : "categoryId"])
        return mapping;
    }
}
