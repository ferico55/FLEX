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
        let mapping = RKObjectMapping(for: MyWishlistResponse.self)
        mapping!.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: MyWishlistData.mapping()))
        mapping!.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "pagination", toKeyPath: "pagination", with: Paging.mappingForWishlist()))
        mapping!.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "header", toKeyPath: "header", with: GeneralMetaData.mapping()))
        return mapping!
    }
}
