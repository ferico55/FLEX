//
//  GoldMerchantTarget.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 5/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import MoyaUnbox
import Moya

enum GoldMerchantTarget{
    case getProductVideos(withProductID: String)
}

extension GoldMerchantTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.goldMerchantUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getProductVideos(let productID):
            return "/v1/product/video/\(productID)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getProductVideos: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        default: return [:]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
