//
//  CategoryIntermediaryCuratedProduct.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class CategoryIntermediaryCuratedProduct: NSObject, Unboxable {
    var categoryId: Int = 0
    var sections: [CategoryIntermediaryCuratedProductSection]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryCuratedProduct.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "sections", toKeyPath: "sections", with: CategoryIntermediaryCuratedProductSection.mapping()))
        mapping.addAttributeMappings(from:["category_id" : "categoryId"])
        return mapping;
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.categoryId = try unboxer.unbox(keyPath: "category_id")
        self.sections = try unboxer.unbox(keyPath: "sections")
    }
}
