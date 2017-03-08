//
//  DiscoverResult.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class DiscoverResult: NSObject {
    var providers: [SignInProvider]!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        let providerMapping = RKRelationshipMapping(fromKeyPath: "providers", toKeyPath: "providers", with: SignInProvider.mapping())!
        
        mapping?.addPropertyMapping(providerMapping)
        return mapping!
    }
}
