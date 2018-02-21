//
//  TokoCashProvider.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 20/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox
import enum Result.Result

final public class TokoCashNetworkPlugin: PluginType {
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success: break
        case let .failure(error):
            if case let .underlying(responseError) = error,
                responseError._code == NSURLErrorNotConnectedToInternet {
                StickyAlertView.showErrorMessage(["Tidak ada koneksi internet."])
            }
        }
    }
}

internal class TokoCashNetworkProvider: NetworkProvider<TokoCashTarget> {
    public init() {
        super.init(
            endpointClosure: TokoCashNetworkProvider.endpointClosure,
            manager: DefaultAlamofireManager.sharedManager,
            plugins: [NetworkLoggerPlugin(verbose: true), TokoCashNetworkPlugin()]
        )
    }
    
    final public class func defaultEndpointCreatorTokocash(for target: TokoCashTarget) -> Endpoint<TokoCashTarget> {
        let hmac = TkpdHMAC()
        
        let headers = [
            "X-Tkpd-UserId": UserAuthentificationManager().getUserId()!
        ]
        
        let parameters = target.parameters
        
        hmac.signature(
            withBaseUrlWallet: target.baseURL.absoluteString,
            method: target.method.rawValue,
            path: target.path,
            parameter: parameters
        )
        
        return Endpoint<TokoCashTarget>(
            url: target.baseURL.appendingPathComponent(target.path).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: parameters,
            parameterEncoding: target.parameterEncoding,
            httpHeaderFields: headers
        ).adding(httpHeaderFields: hmac.authorizedHeaders())
    }
    
    fileprivate class func endpointClosure(for target: TokoCashTarget) -> Endpoint<TokoCashTarget> {
        switch target {
        case .getPendingCashBack:
            let headers = [
                "X-Msisdn": UserAuthentificationManager().getUserPhoneNumber() ?? ""
            ]
            return TokoCashNetworkProvider.defaultEndpointCreatorTokocash(for: target)
                .adding(
                    httpHeaderFields: headers
                )
        default:
            let userManager = UserAuthentificationManager()
            let userInformation = userManager.getUserLoginData()
            let type = userInformation?["oAuthToken.tokenType"] as? String ?? ""
            let tokoCashToken = userManager.getTokoCashToken() ?? ""
            
            let headers: [String: String] = [
                "Authorization": "\(type) \(tokoCashToken)"
            ]
            
            return TokoCashNetworkProvider.defaultEndpointCreator(for: target)
                .adding(httpHeaderFields: headers)
        }
        
    }
}

public enum TokoCashTarget {
    case getPendingCashBack(phoneNumber: String)
    case sendOTP(phoneNumber: String, accept: OTPAcceptType)
    case verifyOTP(phoneNumber: String, otpCode: String)
    case checkPhoneNumber(phoneNumber: String)
    case getCodeFromTokocash(key: String, email: String)
    case balance()
    case walletHistory(parameter: [String: Any])
    case profile()
    case action(URL: String, method: String, parameter: [String: String])
    case revokeAccount(revokeToken: String, identifier: String, identifierType: String)
    case QRInfo(identifier: String)
    case payment(amount: Int, notes: String, merchantIdentifier: String)
    case help(message: String, category: String, transactionId: String)
}

extension TokoCashTarget: TargetType {
    /// The target's base `URL`.
    public var baseURL: URL { return URL(string: NSString.tokocashUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getPendingCashBack : return "/api/v1/me/cashback/balance"
        case .sendOTP: return "/oauth/otp"
        case .verifyOTP: return "/oauth/verify_native"
        case .checkPhoneNumber: return "/oauth/check/msisdn"
        case .getCodeFromTokocash: return "/oauth/authorize_native"
        case .balance: return "/api/v1/wallet/balance"
        case .walletHistory: return "/api/v1/me/history"
        case .profile: return "/api/v1/me/profile"
        case let .action(URL, _, _):
            return URL
        case .revokeAccount: return "/api/v1/me/client/revoke"
        case let .QRInfo(identifier):
            return "/api/v1/qr/\(identifier)"
        case .payment : return "/api/v1/paymentqr"
        case .help: return "/api/v1/cs/complaint"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .getPendingCashBack: return .get
        case .sendOTP: return .post
        case .verifyOTP: return .post
        case .checkPhoneNumber: return .post
        case .getCodeFromTokocash: return .post
        case .balance: return .get
        case .walletHistory: return .get
        case .profile: return .get
        case let .action(_, method, _):
            return method.lowercased() == "post" ? .post : .get
        case .revokeAccount : return .post
        case .QRInfo : return .get
        case .payment: return .post
        case .help: return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case let .getPendingCashBack(phoneNumber) :
            return ["msisdn": phoneNumber]
        case let .sendOTP(phoneNumber, accept):
            return [
                "msisdn": phoneNumber,
                "accept": accept.rawValue
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
                "key": key,
                "email": email
            ]
        case let .walletHistory(parameter):
            return parameter
        case let .action(_, _, parameter):
            return parameter
        case let .revokeAccount(revokeToken, identifier, identifierType):
            return [
                "revoke_token": revokeToken,
                "identifier": identifier,
                "identifier_type": identifierType
            ]
        case let .QRInfo(identifier):
            return [
                "identifier": identifier
            ]
        case let .payment(amount, notes, merchantIdentifier):
            return [
                "amount": amount,
                "note_to_payer": notes,
                "merchant_identifier": merchantIdentifier
            ]
        case let .help(message, category, transactionId):
            return [
                "subject": "Tokocash",
                "message": message,
                "category": category,
                "transaction_id": transactionId
            ]
        default: return [:]
        }
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .action: return JSONEncoding.default
        case .payment: return JSONEncoding.default
        case .help: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data { return Data() }
    
    /// The type of HTTP task to be performed.
    public var task: Task { return .request }
    
}
