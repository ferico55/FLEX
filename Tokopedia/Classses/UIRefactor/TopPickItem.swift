//
//  TopPickItem.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class TopPickItem: NSObject {
    var name: String!
    var imageUrl: String!
    var url: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: TopPickItem.self)
        
        mapping.addAttributeMappingsFromDictionary(["name" : "name", "image_url" : "imageUrl", "url" : "url"])
        return mapping
    }
}
