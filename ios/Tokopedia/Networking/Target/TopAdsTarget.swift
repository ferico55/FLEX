//
//  TopAdsTarget.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 8/30/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya

class TopAdsProvider: RxMoyaProvider<TopAdsTarget> {
    
    init() {
        super.init(endpointClosure: TopAdsProvider.endpointClosure,
                   manager: DefaultAlamofireManager.sharedManager,
                   plugins: [NetworkLoggerPlugin(verbose: true),NetworkPlugin()])
    }
    
    private static func endpointClosure(target: TopAdsTarget) -> Endpoint<TopAdsTarget> {
        return NetworkProvider.defaultEndpointCreator(for: target)
    }
    
}

enum TopAdsTarget{
    case getTopAds(adFilter: TopAdsFilter)
}

extension TopAdsTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.topAdsUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getTopAds:
            return "/promo/v1.2/display/ads"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getTopAds:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getTopAds(adFilter) :
            return TopAdsService.generateParameters(adFilter: adFilter)
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
