//
//  ScroogeTarget.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/20/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

import MoyaUnbox
import Moya

class ScroogeProvider: NetworkProvider<ScroogeTarget> {
    init() {
        super.init(endpointClosure: ScroogeProvider.endpointClosure,
                   manager: DefaultAlamofireManager.sharedManager)
    }

    fileprivate class func endpointClosure(for target: ScroogeTarget) -> Endpoint<ScroogeTarget> {
        let userID = UserAuthentificationManager().getUserId() ?? ""
        let appVersion = UIApplication.getAppVersionString()

        let jsonHeaders = target.method == .get ? [:] : [
            "Accept": "application/json",
            "X-APP-VERSION": appVersion,
            "X-Device": "ios-\(appVersion)",
            "Accept-Language": "id-ID",
            "Accept-Encoding": "gzip",
            "X-Tkpd-UserId": userID,
            "Content-Type": "application/json"
        ]

        let headers = target.parameterEncoding is Moya.JSONEncoding ? jsonHeaders : [:]

        return NetworkProvider.defaultEndpointCreator(for: target)
            .adding(
                httpHeaderFields: headers
            )
    }
}

enum ScroogeTarget {
    case getListOneClick()
    case getOneClickAccessToken()
    case registerOneClick(OneClickData)
    case editOneClick(OneClickData)
    case deleteOneClick(String)
    case getListCreditCard()
    case deleteCreditCard(String)
    case getCCAuthenticationStatus()
    case updateCCAuthenticationStatus(Int)
    case register(PublicKey: String, signature: String, transactionID: String, ccHash: String, dateString: String)
    case validatePayment(PublicKey: String, signature: String, parameter: [String: Any], dateString: String)
}

extension String {
    func hmac(key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        let length: Int = Int(strlen(cKey!))
        let data: Int = Int(strlen(cData!))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey!, length, cData!, data, &result)

        let hmacData: NSData = NSData(bytes: result, length: Int(CC_SHA1_DIGEST_LENGTH))

        var bytes = [UInt8](repeating: 0, count: hmacData.length)
        hmacData.getBytes(&bytes, length: hmacData.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02hhx", UInt8(byte))
        }
        return hexString
    }
}

extension ScroogeTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {

        let string: String
        switch self {
        case .getListCreditCard, .deleteCreditCard, .register, .validatePayment:
            string = NSString.creditCardURL()
        default:
            string = NSString.oneClickURL()
        }

        return URL(string: string)!
    }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getListOneClick: return "/ws/oneclick"
        case .getOneClickAccessToken: return "/ws/oneclick"
        case .registerOneClick: return "/ws/oneclick"
        case .editOneClick: return "/ws/oneclick"
        case .deleteOneClick: return "/ws/oneclick"
        case .getListCreditCard: return "/v2/ccvault/metadata"
        case .deleteCreditCard: return "/v2/ccvault/delete"
        case .getCCAuthenticationStatus: return "/zeus/whitelist/status"
        case .updateCCAuthenticationStatus: return "/zeus/whitelist"
        case .register: return "/v2/fingerprint/publickey/save"
        case .validatePayment: return "/v2/payment/cc/fingerprint"
        }
    }

    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .post
    }

    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        let authManager = UserAuthentificationManager()
        switch self {
        case .getListOneClick:
            return [
                "action": "get",
                "tokopedia_user_id": authManager.getUserId(),
                "merchant_code": "tokopedia"
            ]
        case .getOneClickAccessToken:
            return [
                "action": "auth",
                "tokopedia_user_id": authManager.getUserId(),
                "merchant_code": "tokopedia",
                "profile_code": "TKPD_DEFAULT"
            ]
        case let .registerOneClick(userData):
            return [
                "action": "add",
                "tokopedia_user_id": authManager.getUserId(),
                "merchant_code": "tokopedia",
                "token_id": userData.tokenID,
                "credential_type": userData.credentialType,
                "credential_no": userData.credentialNumber,
                "max_limit": userData.maxLimit
            ]
        case let .editOneClick(userData):
            return [
                "action": "edit",
                "tokopedia_user_id": authManager.getUserId(),
                "merchant_code": "tokopedia",
                "token_id": userData.tokenID,
                "credential_type": userData.credentialType,
                "credential_no": userData.credentialNumber,
                "max_limit": userData.maxLimit
            ]
        case let .deleteOneClick(tokenID):
            return [
                "action": "delete",
                "tokopedia_user_id": authManager.getUserId(),
                "merchant_code": "tokopedia",
                "token_id": tokenID
            ]
        case .getListCreditCard:
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let usLocale = Locale(identifier: "en_US")
            formatter.locale = usLocale as Locale
            let dateString = formatter.string(from: Date())
            let userID = authManager.getUserId() ?? ""

            let signatureString = "\(userID)tokopedia\(dateString)"
            return [
                "merchant_code": "tokopedia",
                "date": dateString,
                "user_id": userID,
                "signature": signatureString.hmac(key: NSString.creditCardSecretKey())
            ]
        case let .deleteCreditCard(tokenID):
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let usLocale = Locale(identifier: "en_US")
            formatter.locale = usLocale as Locale
            let dateString = formatter.string(from: Date())
            let userID = authManager.getUserId() ?? ""

            let signatureString = "\(userID)tokopedia\(dateString)"
            return [
                "token_id": tokenID,
                "merchant_code": "tokopedia",
                "date": dateString,
                "user_id": userID,
                "signature": signatureString.hmac(key: NSString.creditCardSecretKey())
            ]
        case .getCCAuthenticationStatus() :
            let email = authManager.getUserEmail() ?? ""
            let secretKey: String
            if self.baseURL.absoluteString.contains("staging") {
                secretKey = "zeuswhitelist"
            } else {
                secretKey = "abf49d067c9ca8585f3a1059464d22b9"
            }
            return [
                "data" : [[ "user_email" : email ]],
                "signature": email.hmac(key: secretKey)
            ]
        case let .updateCCAuthenticationStatus(status) :
            let email = authManager.getUserEmail() ?? ""
            let signatureString = "\(email)\(status)"
            let secretKey: String
            if self.baseURL.absoluteString.contains("staging") {
                secretKey = "zeuswhitelist"
            } else {
                secretKey = "abf49d067c9ca8585f3a1059464d22b9"
            }
            return [
                "data" : [[ "user_email" : email ,
                            "state":status
                    ]],
                "signature": signatureString.hmac(key: secretKey)
        ]
        case let .register(publicKey, signature, transactionID, ccHash, dateString):

            let auth = UserAuthentificationManager()
            
            return [
                "public_key": publicKey,
                "date": dateString,
                "account_signature": signature,
                "user_id": auth.getUserId(),
                "os": "2",
                "transaction_id": transactionID,
                "cc_hashed": ccHash
            ]

        case let .validatePayment(publicKey, signature, parameter, dateString):

            let auth = UserAuthentificationManager()
            
            let param = parameter.combineWith(values: [
                "public_key": publicKey,
                "date": dateString,
                "account_signature": signature,
                "user_id": auth.getUserId(),
                "os": "2"
                ])
            
            return param
    }
    }

    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getListCreditCard, .deleteCreditCard, .getCCAuthenticationStatus, .updateCCAuthenticationStatus: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }

    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }

    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
