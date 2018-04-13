//
//  VoucherTarget.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 3/29/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya

internal enum VoucherTarget {
    case cancelVoucher()
}

extension VoucherTarget: TargetType {
    /// The target's base `URL`.
    internal var baseURL: URL { return URL(string: NSString.apiURL())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    internal var path: String {
        switch self {
        case .cancelVoucher: return "/cart/v2/auto_applied_kupon/clear"
        }
    }
    
    /// The HTTP method used in the request.
    internal var method: Moya.Method {
        switch self {
        case .cancelVoucher: return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    internal var parameters: [String: Any]? {
        switch self {
        case .cancelVoucher: return [:]
        default:
            return [:]
        }
    }
    
    /// The method used for parameter encoding.
    internal var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    /// Provides stub data for use in testing.
    internal var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    internal var task: Task { return .request }
}
