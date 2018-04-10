//
//  PaymentTarget.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox
import UIKit

public enum PaymentTarget {
    case getPaymentStatus(String)
    case cancelPayment(String)
    case ccRegistrationIframe()
}

extension PaymentTarget: TargetType {
    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: NSString.paymentURL())!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getPaymentStatus: return "/get_payment_status"
        case .cancelPayment: return "/cancel"
        case .ccRegistrationIframe: return "/ccvault/ws/ccregister/iframe"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .getPaymentStatus: return .get
        case .cancelPayment: return .post
        case .ccRegistrationIframe: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case let .getPaymentStatus(paymentID):
            return ["payment_id": paymentID]
        case let .cancelPayment(paymentID):
            return ["payment_id": paymentID]
        case .ccRegistrationIframe:
            let auth = UserAuthentificationManager()
            let userId = auth.getUserId() ?? ""
            return [
                "user_id": userId,
                "device": "ios"
            ]
        }
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        switch self {
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    public var task: Task { return .request }
}
