//
//  CategoryIntermediaryProduct.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class CategoryIntermediaryProduct: NSObject, Unboxable {
    var id: String = ""
    var departmentId: Int = 0
    var condition: Int = 0
    var imageUrl: String = ""
    var badges: [ProductBadge]!
    var name: String = ""
    var price: String = ""
    var rating: Int = 0
    var url: String = ""
    var wholesalePrice: String? = ""
    var labels: [ProductLabel]!
    var shop: CategoryIntermediaryProductShop!
    var applinks: String = ""
    var isOnWishlist = false
    
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

    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.id = try unboxer.unbox(keyPath: "id")
        self.condition = try unboxer.unbox(keyPath: "condition")
        self.name = try unboxer.unbox(keyPath: "name")
        self.price = try unboxer.unbox(keyPath: "price")
        self.rating = try unboxer.unbox(keyPath: "rating")
        self.url = try unboxer.unbox(keyPath: "url")
        self.applinks = try unboxer.unbox(keyPath: "applinks")
        self.departmentId = try unboxer.unbox(keyPath: "department_id")
        self.imageUrl = try unboxer.unbox(keyPath: "image_url")
        self.wholesalePrice = try? unboxer.unbox(keyPath: "wholesale_price") as String
        self.badges = try unboxer.unbox(keyPath: "badges")
        self.labels = try unboxer.unbox(keyPath: "labels")
        self.shop = try unboxer.unbox(keyPath: "shop")
    }
}
