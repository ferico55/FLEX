//
//  MyWishlistLabel.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(MyWishlistLabel)
class MyWishlistLabel: NSObject {
    
    var title: String!
    var color: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: MyWishlistLabel.self)
        mapping.addAttributeMappingsFromArray(["title", "color"])
        
        return mapping
    }
}

