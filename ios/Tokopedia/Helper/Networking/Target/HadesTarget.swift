//
//  HadesTarget.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

import Moya

enum HadesTarget{
    case getCategoryIntermediary(forCategoryID:String)
}

extension HadesTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.hadesUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case let .getCategoryIntermediary(categoryID): return "/v1/categories/\(categoryID)/detail"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getCategoryIntermediary: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getCategoryIntermediary :
            return [:]
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
