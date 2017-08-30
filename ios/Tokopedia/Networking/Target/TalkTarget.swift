//
//  TalkTarget.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 8/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum TalkTarget {
    case getLatestTalk(withProductID: String)
    case getTalkComment(withTalkID: String)
}

extension TalkTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: NSString.kunyitUrl())!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getLatestTalk: return "/talk/v2/read"
        case .getTalkComment: return "/talk/v2/comment"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getLatestTalk(productID):
            return ["product_id": productID,
                    "sort": "newest",
                    "page": 1]
        case let .getTalkComment(talkID):
            return ["talk_id": talkID]
        default :
            return [ : ]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
