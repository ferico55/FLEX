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
        let mapping = RKObjectMapping(for: TopPicksGroup.self)
        
        mapping!.addAttributeMappings(from: ["name"])
        mapping!.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "toppicks", toKeyPath: "toppicks", with: TopPick.mapping()))
        
        return mapping!
    }
}
