//
//  TriggerCampaignTarget.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 31/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox
import enum Result.Result

internal class TriggerCampaignNetworkProvider: NetworkProvider<TriggerCampaignTarget> {
    public init() {
        super.init(
            endpointClosure: TriggerCampaignNetworkProvider.endpointClosure,
            manager: DefaultAlamofireManager.sharedManager,
            plugins: [NetworkLoggerPlugin(verbose: true), TokoCashNetworkPlugin()]
        )
    }
    
    fileprivate class func endpointClosure(for target: TriggerCampaignTarget) -> Endpoint<TriggerCampaignTarget> {
        return NetworkProvider.defaultEndpointCreator(for: target)
    }
}

public enum TriggerCampaignTarget {
    case QRTriggerCampaign(identifier: String)
}

extension TriggerCampaignTarget: TargetType {
    /// The target's base `URL`.
    public var baseURL: URL { return URL(string: NSString.bookingUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .QRTriggerCampaign : return "/trigger/v1/api/campaign/qr/verify"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .QRTriggerCampaign: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case let .QRTriggerCampaign(identifier):
            return ["tkp_campaign_id": identifier]
        }
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data { return Data() }
    
    /// The type of HTTP task to be performed.
    public var task: Task { return .request }
    
}
