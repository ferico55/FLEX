//
//  NetworkProviderTokocash.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class TokocashNetworkProvider: NetworkProvider<TokocashTarget> {
    
    final class func defaultEndpointCreatorTokocash(for target: TokocashTarget) -> Endpoint<TokocashTarget> {
        let hmac = TkpdHMAC()
        
        let headers = [
            "X-Tkpd-UserId": UserAuthentificationManager().getUserId()!
        ]
        
        let parameters = target.parameters
        
        hmac.signature(
            withBaseUrlWallet: target.baseURL.absoluteString,
            method: target.method.rawValue,
            path: target.path,
            parameter: parameters
        )
        
        return Endpoint<TokocashTarget>(
            url: target.baseURL.appendingPathComponent(target.path).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: parameters,
            parameterEncoding: target.parameterEncoding,
            httpHeaderFields: headers
        ).adding(httpHeaderFields: hmac.authorizedHeaders())
    }
}
