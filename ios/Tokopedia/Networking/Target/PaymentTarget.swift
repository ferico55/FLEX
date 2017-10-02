//
//  PaymentTarget.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

import MoyaUnbox
import Moya

enum PaymentTarget {
    case getPaymentStatus(String)
    case cancelPayment(String)
}

extension PaymentTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.paymentURL())!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getPaymentStatus: return "/get_payment_status"
        case .cancelPayment: return "/cancel"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getPaymentStatus: return .get
        case .cancelPayment: return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getPaymentStatus(paymentID):
            return ["payment_id": paymentID]
        case let .cancelPayment(paymentID):
            return ["payment_id": paymentID]
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
