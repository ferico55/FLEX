//
//  MyWishlistResponse-Swift.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(MyWishlistResponse)
class MyWishlistResponse: NSObject {
    
    var data: [MyWishlistData]!
    var pagination: Paging!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: MyWishlistResponse.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: MyWishlistData.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "pagination", toKeyPath: "pagination", withMapping: Paging.mappingForWishlist()))
        return mapping
    }
}