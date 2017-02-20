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
    var videos: [DetailProductVideo]!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: DetailProductVideoData.self)
        mapping?.addAttributeMappings(from:["product_id"])
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "video", toKeyPath: "videos", with: DetailProductVideo.mapping()))
        return mapping!
    }
}
