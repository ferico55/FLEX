//
//  MyWishlistShop.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(MyWishlistShop)
class MyWishlistShop: NSObject {
    
    var id: String!
    var name: String!
    var url: String!
    var reputation: MyWishlistShopReputation!
    var gold_merchant: Bool = false
    var lucky_merchant: String!
    var location: String!
    var status: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: MyWishlistShop.self)
        
        mapping?.addAttributeMappings(from:["id", "name", "url", "gold_merchant", "lucky_merchant", "location", "status"])
        
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "reputation", toKeyPath: "reputation", with: MyWishlistShopReputation.mapping()))
        
        return mapping!
    }
}
