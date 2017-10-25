//
//  GaladrielTarget.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 10/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum GaladrielTarget {
    case getPromoWidget()
}

extension GaladrielTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.galadrielURL())! //URL(string: "https://private-7a9b0-galadriel.apiary-mock.com")! //
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getPromoWidget: return "/promo-suggestions/v1/widget" //"promo-suggestions/widget?user_id=123&device_type=android&target_type=guest&placeholder=pdp_widget&lang=id" //
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getPromoWidget: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .getPromoWidget():
            return [:]
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
