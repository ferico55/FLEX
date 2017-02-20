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
        let mapping = RKObjectMapping(for: TopPicksResponse.self)
        
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: TopPicksResponseData.mapping()))
        
        return mapping!
    }
}
