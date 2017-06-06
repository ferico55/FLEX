//
//  AceProvider.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya

class AceProvider : NetworkProvider<AceTarget> {
    init() {
        super.init(endpointClosure: AceProvider.endpointClosure)
    }
    
    fileprivate class func endpointClosure(for target: AceTarget) -> Endpoint<AceTarget> {
        let userId = UserAuthentificationManager().getUserId()!
        
        return NetworkProvider.defaultEndpointCreator(for: target)
    }
    
}
