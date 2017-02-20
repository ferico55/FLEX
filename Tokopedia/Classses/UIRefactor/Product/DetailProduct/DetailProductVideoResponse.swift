//
//  DetailProductVideoResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc (DetailProductVideoResponse)
class DetailProductVideoResponse: NSObject {
    
    var links: DetailProductVideoLinks!
    var data: [DetailProductVideoData]!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: DetailProductVideoResponse.self)
        
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "links", toKeyPath: "links", with: DetailProductVideoLinks.mapping()))
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: DetailProductVideoData.mapping()))
        
        return mapping!
    }
}
