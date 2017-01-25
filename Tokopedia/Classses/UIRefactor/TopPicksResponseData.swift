//
//  TopPicksResponseData.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class TopPicksResponseData: NSObject {
    var groups: [TopPicksGroup]!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: TopPicksResponseData.self)

        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "groups", toKeyPath: "groups", withMapping: TopPicksGroup.mapping()))
        
        return mapping
    }
}
