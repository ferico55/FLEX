//
//  TopPick.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class TopPick: TopPickItem {
    var items: [TopPickItem]!
    
    override class func mapping() -> RKObjectMapping {
       let mapping = RKObjectMapping(forClass: TopPick.self)
      mapping.addAttributeMappingsFromDictionary(["name" : "name", "image_url" : "imageUrl", "url" : "url"])
       mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "item", toKeyPath: "items", withMapping: TopPickItem.mapping()))
        
        return mapping
    }
}
