//
//  CategoryIntermediaryHotListItem.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryHotListItem: NSObject {
    var hotProductId: String = ""
    var priceStartFrom: String = ""
    var url: String = ""
    var title: String = ""
    var alk: String = ""
    var imgPortrait: CategoryIntermediaryHotListImagePortrait!
    var img: CategoryIntermediaryHotListImage!
    var imgSquare: CategoryIntermediaryHotListImageSquare!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryHotListItem.self)
        mapping.addAttributeMappings(from:["hot_product_id" : "hotProductId", "price_start_from" : "priceStartFrom"])
        mapping.addAttributeMappings(from:["url", "title", "alk"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "img_portrait", toKeyPath: "imgPortrait", with: CategoryIntermediaryHotListImagePortrait.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "img", toKeyPath: "img", with: CategoryIntermediaryHotListImage.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "img_square", toKeyPath: "imgSquare", with: CategoryIntermediaryHotListImageSquare.mapping()))
        return mapping;
    }
}
