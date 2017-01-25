//
//  TopPicksGroup.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 1/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

class TopPicksGroup: NSObject {
    
    var name: String!
    var toppicks: [TopPick]!

    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: TopPicksGroup.self)
        
        mapping.addAttributeMappingsFromArray(["name"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "toppicks", toKeyPath: "toppicks", withMapping: TopPick.mapping()))
        
        return mapping
    }
}
