//
//  NotificationTarget.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum NotificationTarget {
    case getNotifications
    case resetNotifications
}

// MARK: - TargetType Protocol Implementation
extension NotificationTarget: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.v4Url())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getNotifications: return "/v4/notification/get_notification.pl"
        case .resetNotifications: return "/v4/notification/reset_notification.pl"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getNotifications: return .get
        case .resetNotifications: return .get
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
