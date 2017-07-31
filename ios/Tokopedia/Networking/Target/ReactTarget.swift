//
//  ReactTarget.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 5/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya

@objc(ReactNetworkProvider)
class ReactNetworkProviderObjcBridge: NSObject {
    class func request(
        withBaseUrl url: String,
        path: String,
        method: String,
        params: [String: Any],
        headers: [String: String]?,
        onSuccess: @escaping ([String: Any]?) -> Void,
        onError: @escaping (NSError) -> Void
        ) {
        
        let target = ReactTarget(targetBaseUrl: url, targetPath: path, targetMethod: method, params: params)
        
        let endpointClosure = { (target: ReactTarget) in
            return NetworkProvider<ReactTarget>.defaultEndpointCreator(for: target)
                .adding(httpHeaderFields: headers ?? [:])
        }
        
        _ = NetworkProvider<ReactTarget>(endpointClosure: endpointClosure).request(target)
            .mapJSON(failsOnEmptyData: false)
            .subscribe(
                onNext: { json in
                    guard let dictionary = json as? [String: Any] else {
                        print("Error converting json to dictionary")
                        onSuccess(nil)
                        return
                    }
                    
                    onSuccess(dictionary)
                },
                onError: { error in
                    onError(error as NSError)
                }
        )
    }
}

struct ReactTarget {
    let targetBaseUrl: String
    let targetPath: String
    let targetMethod: String
    let params: [String: Any]
}

extension ReactTarget: TargetType {
    var baseURL: URL {
        return URL(string: targetBaseUrl)!
    }
    
    var method: Moya.Method {
        return Moya.Method(rawValue: targetMethod) ?? .get
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var parameters: [String: Any]? {
        return params
    }
    
    var path: String {
        return targetPath
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .request
    }
}
