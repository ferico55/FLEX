//
//  GaladrielTarget.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 10/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum GaladrielTarget {
    case getPromoWidget(shopType: String)
}

extension GaladrielTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.galadrielURL())!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getPromoWidget: return "/promo-suggestions/v1/widget"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getPromoWidget: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getPromoWidget(shopType):
            return [
                "target_type": getUserType(),
                "shop_type": shopType
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

func getUserType() -> (String) {
    let userAuth = UserAuthentificationManager()
    if userAuth.userIsGoldMerchant() {
        return "gold_merchant"
    } else if userAuth.userIsSeller() {
        return "merchant"
    } else if userAuth.isLogin {
        return "login_user"
    } else {
        return "guest"
    }
}
