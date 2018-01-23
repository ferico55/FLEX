//
//  WalletTarget.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

class WalletProvider: NetworkProvider<WalletTarget> {
    init() {
        super.init(endpointClosure: WalletProvider.endpointClosure,
                   manager: DefaultAlamofireManager.sharedManager,
                   plugins: [NetworkLoggerPlugin(verbose: true), TokoCashNetworkPlugin()])
    }
    
    fileprivate class func endpointClosure(for target: WalletTarget) -> Endpoint<WalletTarget> {
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        
        let type = userInformation?["oAuthToken.tokenType"] as? String ?? ""
        let token = userInformation?["oAuthToken.accessToken"] as? String ?? ""
        
        let headers = [
            "Authorization": "\(type) \(token)"
        ]
        
        return NetworkProvider.defaultEndpointCreator(for: target)
            .adding(httpHeaderFields: headers)
    }
}

enum WalletTarget {
    case activationTokoCash(verificationCode: String)
    case OTPTokoCash
    case getToken
}

extension WalletTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.accountsUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .activationTokoCash : return "/api/v1/wallet/link"
        case .OTPTokoCash : return "/api/v1/wallet/otp/request"
        case .getToken: return "/api/v1/wallet/token"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .activationTokoCash: return .get
        case .OTPTokoCash: return .get
        case .getToken: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .activationTokoCash(verificationCode):
            if !verificationCode.isEmpty {
                return ["otp": verificationCode]
            } else {
                return [:]
            }
        default: return [:]
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
