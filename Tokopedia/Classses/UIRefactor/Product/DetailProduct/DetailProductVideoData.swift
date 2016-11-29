//
//  DetailProductVideoData.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc (DetailProductVideoData)
class DetailProductVideoData: NSObject {
    
    var product_id: String!
    var video: [DetailProductVideoArray]!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: DetailProductVideoData.self)
        mapping.addAttributeMappingsFromArray(["product_id"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "video", toKeyPath: "video", withMapping: DetailProductVideoArray.mapping()))
        return mapping
    }
}
