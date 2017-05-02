//
//  CategoryIntermediaryProductShop.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryProductShop: NSObject {
    var city: String = ""
    var clover: String = ""
    var id: Int = 0
    var isGold: Bool = false
    var location: String = ""
    var name: String = ""
    var reputation: String = ""
    var url: String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryProductShop.self)
        mapping.addAttributeMappings(from:["city", "clover", "id", "location", "name", "reputation", "url"])
        mapping.addAttributeMappings(from: ["is_gold" : "isGold"])
        return mapping;
    }
}
