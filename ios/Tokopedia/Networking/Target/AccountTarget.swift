//
//  AccountTarget.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 7/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya

internal class AccountProvider: NetworkProvider<AccountTarget> {
    internal init() {
        super.init(endpointClosure: AccountProvider.endpointClosure)
    }
    
    fileprivate class func endpointClosure(for target: AccountTarget) -> Endpoint<AccountTarget> {
        let userManager = UserAuthentificationManager()
        switch target {
        case let .requestCentralizedOtp(_, _, _, userId):
            if userManager.isLogin {
                return NetworkProvider.defaultEndpointCreator(for: target)
            } else {
                guard let typeAndToken = userManager.authenticationHeader else {
                    return NetworkProvider.defaultEndpointCreator(for: target)
                }
                
                let headers = [
                    "Authorization": typeAndToken,
                    "Tkpd-UserId": userId
                ]
                
                return NetworkProvider.defaultEndpointCreator(for: target)
                    .adding(httpHeaderFields: headers)
            }
        case .requestCentralizedOtpToEmail:
            if userManager.isLogin {
                return NetworkProvider.defaultEndpointCreator(for: target)
            } else {
                guard let typeAndToken = userManager.authenticationHeader else {
                    return NetworkProvider.defaultEndpointCreator(for: target)
                }
                
                let headers = [
                    "Authorization": typeAndToken,
                ]
                
                return NetworkProvider.defaultEndpointCreator(for: target)
                    .adding(httpHeaderFields: headers)
            }
        case .centralizedOTPModeList:
            if userManager.isLogin {
                return NetworkProvider.defaultEndpointCreator(for: target)
            }
            else {
                guard let typeAndToken = userManager.authenticationHeader else {
                    return NetworkProvider.defaultEndpointCreator(for: target)
                }
                
                let headers = [
                    "Accounts-Authorization": typeAndToken
                ]
                
                return NetworkProvider.defaultEndpointCreator(for: target)
                    .adding(httpHeaderFields: headers)
            }
        default:
            let userInformation = userManager.getUserLoginData()
            guard let type = userInformation?["oAuthToken.tokenType"] as? String else {
                return NetworkProvider.defaultEndpointCreator(for: target)
            }
            guard let token = userInformation?["oAuthToken.accessToken"] as? String else {
                return NetworkProvider.defaultEndpointCreator(for: target)
            }
            
            let headers = [
                "Authorization": "\(type) \(token)",
            ]
            
            return NetworkProvider.defaultEndpointCreator(for: target)
                .adding(httpHeaderFields: headers)
        }
    }
}

public enum AccountTarget {
    case getInfo
    case editProfile(withBirthday: Date?, gender: Int?)
    case register(email: String, fullName: String, phoneNumber: String, password: String)
    case resendActivationEmail(email: String)
    case verifyOTP(withParams: [String : Any]?)
    case registerPublicKey(withKey: String)
    case centralizedOTPModeList(otpType: CentralizedOTPType, userId: String)
    case requestCentralizedOtp(otpType: CentralizedOTPType, modeDetail: ModeListDetail, phoneNumber: String, userId: String)
    case requestCentralizedOtpToEmail(userId: String, userEmail: String, otpType: CentralizedOTPType)
    case validateCentralizedOtp(userId: String, code: String, otpType: CentralizedOTPType)
    case updateGCM
}

extension AccountTarget: TargetType {
    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: NSString.accountsUrl())!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getInfo: return "/info"
        case .editProfile: return "/api/v1/user/profile-edit"
        case .register: return "/api/register"
        case .resendActivationEmail: return "/api/v1/resend"
        case .verifyOTP(_): return "/otp/verify"
        case .registerPublicKey(_): return "/otp/fingerprint/add"
        case .centralizedOTPModeList: return "/otp/ws/mode-list"
        case .requestCentralizedOtp: return "/otp/request"
        case .requestCentralizedOtpToEmail: return "/otp/email/request"
        case .validateCentralizedOtp: return "/otp/validate"
        case .updateGCM: return "/api/gcm/update"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .getInfo: return .get
        case .editProfile: return .post
        case .register: return .post
        case .resendActivationEmail, .verifyOTP, .registerPublicKey : return .post
        case .centralizedOTPModeList, .requestCentralizedOtp, .requestCentralizedOtpToEmail, .validateCentralizedOtp : return .get
        case .updateGCM: return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case .getInfo():
            return [:]
        case let .editProfile(birthday, gender):
            let (day, month, year) = getBirthdayComponents(birthday: birthday)
            return [
                "bday_dd": day,
                "bday_mm": month,
                "bday_yy": year,
                "gender": gender ?? 0,
            ]
        case let .register(email, fullName, phoneNumber, password):
            return [
                "email": email,
                "full_name": fullName,
                "phone": phoneNumber,
                "password": password,
                "confirm_password": password,
                "birth_day": 1, // default value is 1
                "birth_month": 1, // default value is 1
                "birth_year": 1, // default value is 1
            ]
        case let .resendActivationEmail(email):
            return [
                "email": email
            ]
        case let .verifyOTP(params):
            return params
        case let .registerPublicKey(key) :
            let user = UserAuthentificationManager()
            return ["public_key" : key, "user_id" : user.getUserId()]
        case let .centralizedOTPModeList(otpType, userId) :
            return ["otp_type" : otpType.rawValue, "user_id" : userId]
        case let .requestCentralizedOtp(otpType, modeDetail, phoneNumber, _):
            return ["otp_type": otpType.rawValue, "msisdn": phoneNumber , "mode": modeDetail.modeText]
        case let .requestCentralizedOtpToEmail(userId, userEmail, otpType):
            return ["type": otpType.rawValue, "user_email": userEmail, "user": userId, "mode": "email"]
        case let .validateCentralizedOtp(userId, code, otpType):
            return ["user": userId, "code": code, "otp_type": otpType.rawValue]
        case .updateGCM():
            let deviceID = UserAuthentificationManager().getMyDeviceToken()
            return ["os_type": 1, "device_id_new": deviceID]
        }
        
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return "{\"data\": 123 }".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    public var task: Task { return .request }
}

private func getBirthdayComponents(birthday: Date?) -> (String, String, String) {
    guard let birthday = birthday else {
        return ("", "", "")
    }
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.day, .month, .year], from: birthday)
    
    return ("\(components.day!)", "\(components.month!)", "\(components.year!)")
}
