//
//  ReferralService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 05/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

internal enum ReferralService {
    case getVoucherCode()
}
extension ReferralService: TargetType {
    internal var baseURL: URL {
        let baseUrl = NSString.v4Url()
        return URL(string: baseUrl)!
    }
    internal var path: String {
        switch self {
        case .getVoucherCode: return "/galadriel/promos/referral/code"
        }
    }
    internal var method: Moya.Method {
        switch self {
        case .getVoucherCode: return .post
        }
    }
    internal var parameters: [String: Any]? {
        switch self {
        case .getVoucherCode():
            var data: [String:Any] = [:]
            if let msisdn = UserAuthentificationManager().getUserPhoneNumber(), let userId = UserAuthentificationManager().getUserId() {
                data["msisdn"] = msisdn
                data["user_id"] = Int(userId)
            }
            return ["data":data]
        }
    }
    internal var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    internal var sampleData: Data { return Data()}
    internal var task: Task { return .request }
}
