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
        let mapping = RKObjectMapping(for: MyWishlistShopReputation.self)
        
        mapping?.addAttributeMappings(from:["score", "set", "level", "image"])
        return mapping!
    }
}
