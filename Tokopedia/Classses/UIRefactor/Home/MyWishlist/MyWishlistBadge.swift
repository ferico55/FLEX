//
//  MyWishlistBadge.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(MyWishlistBadge)
class MyWishlistBadge: NSObject {
    
    var title: String!
    var image_url: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: MyWishlistBadge.self)
        mapping.addAttributeMappingsFromArray(["title", "image_url"])
        
        return mapping
    }
}
