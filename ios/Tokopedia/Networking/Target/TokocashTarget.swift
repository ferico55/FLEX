//
//  TokocashTarget.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

class TokocashProvider: TokocashNetworkProvider {
    init() {
        super.init(endpointClosure: TokocashProvider.endpointClosure)
    }
    
    fileprivate class func endpointClosure(for target: TokocashTarget) -> Endpoint<TokocashTarget> {
        let headers = [
            "X-Msisdn": UserAuthentificationManager().getUserPhoneNumber() ?? ""
        ]
        return TokocashNetworkProvider.defaultEndpointCreatorTokocash(for: target)
            .adding(
                httpHeaderFields: headers
        )
    }
}

enum TokocashTarget {
    case getPendingCashBack(phoneNumber: String)
    case sendOTP(phoneNumber: String, accept: OTPAcceptType)
    case verifyOTP(phoneNumber: String, otpCode: String)
    case checkPhoneNumber(phoneNumber: String)
    case getCodeFromTokocash(key: String, email:String)
}

extension TokocashTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.tokocashUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getPendingCashBack : return "/api/v1/me/cashback/balance"
        case .sendOTP: return "/oauth/otp"
        case .verifyOTP: return "/oauth/verify_native"
        case .checkPhoneNumber: return "/oauth/check/msisdn"
        case .getCodeFromTokocash: return "/oauth/authorize_native"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getPendingCashBack: return .get
        case .sendOTP: return .post
        case .verifyOTP: return .post
        case .checkPhoneNumber: return .post
        case .getCodeFromTokocash: return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getPendingCashBack(phoneNumber) :
            return ["msisdn": phoneNumber]
        case let .sendOTP(phoneNumber, accept):
            return [
                "msisdn": phoneNumber,
                "accept": accept
            ]
        case let .verifyOTP(phoneNumber, otpCode):
            return [
                "msisdn": phoneNumber,
                "otp": otpCode
            ]
        case let .checkPhoneNumber(phoneNumber):
            return [
                "msisdn": phoneNumber
            ]
        case let .getCodeFromTokocash(key, email):
            return [
                "key":key,
                "email":email
            ]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return Data() }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}
