//
//  KeroTarget.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 10/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum KeroTarget {
    case getDistricts(token: String, unixTime: Int, query: String, page: Int)
}

extension KeroTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.keroUrl())!
    }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getDistricts: return "/v2/district-recommendation"
        }
    }

    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getDistricts: return .get
        }
    }

    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getDistricts(token, unixTime, query, page):
            return [
                "token": token,
                "ut": unixTime,
                "query": query,
                "page": page,
            ]
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
