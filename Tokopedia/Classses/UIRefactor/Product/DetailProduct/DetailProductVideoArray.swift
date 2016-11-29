//
//  DetailProductVideoArray.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(DetailProductVideoArray)
class DetailProductVideoArray: NSObject {
    var url: String!
    var type: String!
    var varDefault: Int!
    var status: Int!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: DetailProductVideoArray.self)
        
        mapping.addAttributeMappingsFromDictionary(["varDefault" : "default"])
        mapping.addAttributeMappingsFromArray(["url", "type"])
        
        return mapping
    }
}
