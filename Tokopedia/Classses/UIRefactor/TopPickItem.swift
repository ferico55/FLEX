//
//  TopPickItem.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class TopPickItem: NSObject {
    var name: String!
    var imageUrl: String!
    var url: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: TopPickItem.self)
        
        mapping?.addAttributeMappings(from:["name" : "name", "image_url" : "imageUrl", "url" : "url"])
        return mapping!
    }
}
