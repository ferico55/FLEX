//
//  MojitoProvider.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya

class MojitoProvider : NetworkProvider<MojitoTarget> {
    init() {
        super.init(endpointClosure: MojitoProvider.endpointClosure)
    }
    
    fileprivate class func endpointClosure(for target: MojitoTarget) -> Endpoint<MojitoTarget> {
        let userId = UserAuthentificationManager().getUserId()!
        
        return NetworkProvider.defaultEndpointCreator(for: target)
    }
    
}
