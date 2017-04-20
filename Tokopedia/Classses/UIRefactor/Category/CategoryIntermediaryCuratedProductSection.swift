//
//  CategoryIntermediaryCuratedProductSection.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryCuratedProductSection: NSObject {
    var title: String = ""
    var products: [CategoryIntermediaryProduct]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryCuratedProductSection.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "products", toKeyPath: "products", with: CategoryIntermediaryProduct.mapping()))
        mapping.addAttributeMappings(from:["title"])
        return mapping;
    }
}
