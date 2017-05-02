//
//  TopPick.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class TopPick: TopPickItem {
    var items: [TopPickItem]!
    
    override class func mapping() -> RKObjectMapping {
       let mapping = RKObjectMapping(for: TopPick.self)
      mapping?.addAttributeMappings(from:["name" : "name", "image_url" : "imageUrl", "url" : "url"])
       mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "item", toKeyPath: "items", with: TopPickItem.mapping()))
        
        return mapping!
    }
}
