//
//  ReactTarget.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 5/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxSwift

@objc(ReactNetworkProvider)
class ReactNetworkProviderObjcBridge: NSObject {
    class func request(
        withBaseUrl url: String,
        path: String,
        method: String,
        params: [String: Any],
        headers: [String: String]?,
        encoding: String,
        onSuccess: @escaping (Any?) -> Void,
        onError: @escaping (NSError) -> Void
    ) {
        
        let encodingObject: ParameterEncoding = encoding == "json" ? JSONEncoding.default : URLEncoding.default
        let target = ReactTarget(targetBaseUrl: url, targetPath: path, targetMethod: method, params: params, parameterEncoding: encodingObject)
        
        let endpointClosure = { (target: ReactTarget) in
            NetworkProvider<ReactTarget>.defaultEndpointCreator(for: target)
                .adding(httpHeaderFields: headers ?? [:])
        }
        
        _ = NetworkProvider<ReactTarget>(endpointClosure: endpointClosure).request(target)
            .map { response throws -> Any? in
                // TODO ini harusnya append data ke dalam response
                let json = try response.mapJSON(failsOnEmptyData: false)
                if var dictionary = json as? [String: Any] {
                    dictionary["statusCode"] = response.statusCode
                    return dictionary
                }
                else if let array = json as? [Any] {
                    return array
                }
                else {
                    print("Error converting json to dictionary")
                    return nil
                }
            }
            .subscribe(
                onNext: { data in
                    onSuccess(data)
                },
                onError: { error in
                    let realError: Swift.Error
                    
                    if case let MoyaError.underlying(underlyingError) = error {
                        realError = underlyingError
                    } else {
                        realError = error
                    }
                    
                    onError(realError as NSError)
                }
            )
    }
}

struct ReactTarget {
    let targetBaseUrl: String
    let targetPath: String
    let targetMethod: String
    let params: [String: Any]
    let parameterEncoding: ParameterEncoding
}

extension ReactTarget: TargetType {
    var baseURL: URL {
        return URL(string: targetBaseUrl)!
    }
    
    var method: Moya.Method {
        return Moya.Method(rawValue: targetMethod) ?? .get
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
