//
//  CategoryIntermediaryCuratedProductSection.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class CategoryIntermediaryCuratedProductSection: NSObject, Unboxable {
    var title: String = ""
    var products: [CategoryIntermediaryProduct]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryCuratedProductSection.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "products", toKeyPath: "products", with: CategoryIntermediaryProduct.mapping()))
        mapping.addAttributeMappings(from:["title"])
        return mapping;
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.title = try unboxer.unbox(keyPath: "title");
        self.products = try unboxer.unbox(keyPath: "products");
    }
}
