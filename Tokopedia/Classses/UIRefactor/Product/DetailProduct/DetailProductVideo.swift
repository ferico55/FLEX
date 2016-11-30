//
//  DetailProductVideoArray.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(DetailProductVideo)
class DetailProductVideo: NSObject {
    var url: String!
    var type: String!
    var varDefault: Int!
    var status: NSNumber!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: DetailProductVideo.self)
        
        mapping.addAttributeMappingsFromDictionary(["varDefault" : "default"])
        mapping.addAttributeMappingsFromArray(["url", "type", "status"])
        
        return mapping
    }
}
