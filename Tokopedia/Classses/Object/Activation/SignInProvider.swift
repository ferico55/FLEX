//
//  SignInProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class SignInProvider: NSObject {
    var id: String!
    var name: String!
    var signInUrl: String!
    var imageUrl: String!
    var color: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary([
            "id": "id",
            "name": "name",
            "url": "signInUrl",
            "image": "imageUrl",
            "color": "color"
        ])
        return mapping
    }
}
