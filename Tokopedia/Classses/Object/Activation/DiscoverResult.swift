//
//  DiscoverResult.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DiscoverResult: NSObject {
    var providers: [SignInProvider]!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        let providerMapping = RKRelationshipMapping(fromKeyPath: "providers", toKeyPath: "providers", withMapping: SignInProvider.mapping())!
        
        mapping.addPropertyMapping(providerMapping)
        return mapping
    }
}
