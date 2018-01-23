//
//  SellerInfoTarget.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum SellerInfoTarget {
    case getAllInfo(page: Int, filter: SellerInfoItemSectionId)
    case getNotifications
}

extension SellerInfoTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        switch self {
        case .getAllInfo(_,_):
            return URL(string: NSString.v4Url())!
        case .getNotifications:
            return URL(string: NSString.v4Url())!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getAllInfo(_,_):  return "/sellerinfo/api/v1/info/list"
        case .getNotifications: return "/sellerinfo/api/v1/notification"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getAllInfo(_,_): return .get
        case .getNotifications: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .getAllInfo(let page, let section):
            return ["page":page, "section_id": section.rawValue]
        case .getNotifications: return [:]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
