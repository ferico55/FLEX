//
//  TopPicksResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class TopPicksResponse: NSObject {

    var data: TopPicksResponseData!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: TopPicksResponse.self)
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: TopPicksResponseData.mapping()))
        
        return mapping
    }
}
