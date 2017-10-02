//
//  AccountTarget.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 7/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya

class AccountProvider: NetworkProvider<AccountTarget> {
    init() {
        super.init(endpointClosure: AccountProvider.endpointClosure)
    }

    fileprivate class func endpointClosure(for target: AccountTarget) -> Endpoint<AccountTarget> {
        let userManager = UserAuthentificationManager()
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

enum AccountTarget {
    case getInfo
    case editProfile(withBirthday: Date?, gender: Int?)
    case register(email: String, fullName: String, phoneNumber: String, password: String)
    case resendActivationEmail(email: String)
}

extension AccountTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.accountsUrl())!
    }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getInfo: return "/info"
        case .editProfile: return "/api/v1/user/profile-edit"
        case .register: return "/api/register"
        case .resendActivationEmail: return "/api/v1/resend"
        }
    }

    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getInfo: return .get
        case .editProfile: return .post
        case .register: return .post
        case .resendActivationEmail: return .post
        }
    }

    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
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
        }
    }

    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "{\"data\": 123 }".data(using: .utf8)!
    }

    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}

func getBirthdayComponents(birthday: Date?) -> (String, String, String) {
    guard let birthday = birthday else {
        return ("", "", "")
    }
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.day, .month, .year], from: birthday)

    return ("\(components.day!)", "\(components.month!)", "\(components.year!)")
}
