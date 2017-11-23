//
//  MerlinTarget.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

class MerlinProvider: NetworkProvider<MerlinTarget> {
    
    init() {
        super.init(endpointClosure: MerlinProvider.endpointClosure)
    }
    
    private static func endpointClosure(target: MerlinTarget) -> Endpoint<MerlinTarget> {
        let headers = [
            "Content-Type": "application/json"
        ]
        
        return NetworkProvider.defaultEndpointCreator(for: target)
            .adding(
                httpHeaderFields: headers
        )
    }
    
}

enum MerlinTarget{
    case getProductRecommendation(productTitle: String)
}

extension MerlinTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.merlinUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getProductRecommendation:
            return "/v4/product/category/recommendation"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getProductRecommendation:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getProductRecommendation(productTitle) :
            return
                ["parcel" :
                    [
                        ["data" : ["product_title" : productTitle]]
                    ],
                 "size": 1,
                 "expect": 1,
                 "score": "0"
                ]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
