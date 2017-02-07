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
    var header: GeneralMetaData!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: MyWishlistResponse.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: MyWishlistData.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "pagination", toKeyPath: "pagination", withMapping: Paging.mappingForWishlist()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "header", toKeyPath: "header", withMapping: GeneralMetaData.mapping()))
        return mapping
    }
}
