//
//  TopchatTarget.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum TopchatTarget {
    case getUnreadCount
}

// MARK: - TargetType Protocol Implementation
extension TopchatTarget: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.topChatURL())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getUnreadCount: return "/tc/v1/notif_unreads"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getUnreadCount: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        return [:]
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
