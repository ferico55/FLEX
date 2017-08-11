//
//  MyWishlistLabel.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

@objc(MyWishlistLabel)
class MyWishlistLabel: NSObject {
    
    var title: String!
    var color: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: MyWishlistLabel.self)
        mapping?.addAttributeMappings(from: ["title", "color"])
        
        return mapping!
    }
}

