//
//  TokopointsTarget.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

@objc enum PromoServiceType: Int {
    case marketplace
    case digital
}

let type = [
    PromoServiceType.marketplace: "marketplace",
    PromoServiceType.digital: "digital"
]

enum TokopointsTarget {
    case getDrawerData
    case getCoupons(serviceType: PromoServiceType, productId: String?, categoryId: String?, page: Int64)
}

extension TokopointsTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.tokopointsUrl())!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getDrawerData: return "/tokopoints/api/v1/points/drawer"
        case .getCoupons: return "/tokopoints/api/v1/coupon/list"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getDrawerData: return .get
        case .getCoupons: return.get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        let userManager = UserAuthentificationManager()
        
        switch self {
        case .getDrawerData:
            let userManager = UserAuthentificationManager()
            return ["user_id": userManager.getUserId()]
        case let .getCoupons(serviceType, productId, categoryId, page):
            var params: [String: Any] = [
                "user_id": userManager.getUserId(),
                "page": page,
                "type": type[serviceType] ?? "" as Any
            ]
            if let productId = productId {
                params["product_id"] = productId
            }
            if let categoryId = categoryId {
                params["category_id"] = categoryId
            }
            return params
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "{\"data\": 123 }".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
