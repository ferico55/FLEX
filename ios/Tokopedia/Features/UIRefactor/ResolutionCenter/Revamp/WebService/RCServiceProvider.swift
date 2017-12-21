//
//  RCServiceProvider.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya

class RCServiceProvider: RxMoyaProvider<RCService> {
    init() {
        super.init(endpointClosure: RCServiceProvider.endpointClosure)
    }
    fileprivate class func endpointClosure(for target: RCService) -> Endpoint<RCService> {
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()        
        guard let type = userInformation?["oAuthToken.tokenType"] as? String else {
            return NetworkProvider.defaultEndpointCreator(for: target)
        }
        guard let token = userInformation?["oAuthToken.accessToken"] as? String else {
            return NetworkProvider.defaultEndpointCreator(for: target)
        }
        let headers = [
            "Authorization": "\(type) \(token)",
            "Content-Type": "application/json",
        ]
        headers.combineWith(values: target.headers)
        return NetworkProvider.defaultEndpointCreator(for: target)
            .adding(httpHeaderFields: headers)
    }
}
