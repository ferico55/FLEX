//
//  MyWishlistShopReputation.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(MyWishlistShopReputation)
class MyWishlistShopReputation: NSObject {
    
    var score: NSNumber!
    var set: String!
    var level: NSNumber!
    var image: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: MyWishlistShopReputation.self)
        
        mapping.addAttributeMappingsFromArray(["score", "set", "level", "image"])
        return mapping
    }
}
