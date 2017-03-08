//
//  MyWishlistBadge.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

@objc(MyWishlistBadge)
class MyWishlistBadge: NSObject {
    
    var title: String!
    var image_url: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: MyWishlistBadge.self)
        mapping?.addAttributeMappings(from:["title", "image_url"])
        
        return mapping!
    }
}
