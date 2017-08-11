//
//  MyWishlistWholesalePrice.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

@objc(MyWishlistWholesalePrice)
class MyWishlistWholesalePrice: NSObject {
    
    var minimum: NSNumber!
    var maximum: NSNumber!
    var price: NSNumber!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: MyWishlistWholesalePrice.self)
        mapping?.addAttributeMappings(from:["minimum", "maximum", "price"])
        
        return mapping!
    }
}
