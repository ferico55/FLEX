//
//  DetailProductVideoLinks.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc (DetailProductVideoLinks)
class DetailProductVideoLinks: NSObject {
    
    var varself: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: DetailProductVideoResponse.self)
        mapping.addAttributeMappingsFromDictionary(["varself" : "self"])
        return mapping
    }
}
