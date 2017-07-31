//
//  MojitoProvider.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import MoyaUnbox
import Moya

class MojitoProvider: NetworkProvider<MojitoTarget> {
    init() {
        super.init(endpointClosure: MojitoProvider.endpointClosure)
    }
    
    fileprivate class func endpointClosure(for target: MojitoTarget) -> Endpoint<MojitoTarget> {
        guard let userId = UserAuthentificationManager().getUserId() else {
            return NetworkProvider.defaultEndpointCreator(for: target)
        }
        
        let headers = target.method == .get ? [:] : [
            "X-User-ID": userId,
        ]
        
        return NetworkProvider.defaultEndpointCreator(for: target)
            .adding(
                httpHeaderFields: headers
        )
        
    }
}

enum MojitoTarget{
    case getProductWishStatus(productIds: [String])
    case setWishlist(withProductId: String)
    case unsetWishlist(withProductId: String)
    case getProductCampaignInforFor(productIds:String)
    case requestOfficialStore(categoryId: String)
    case requestOfficialStoreHomePage
}

extension MojitoTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.mojitoUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case let .getProductWishStatus(productIds):
            let userManager = UserAuthentificationManager()
            var url = "/v1/users/\(userManager.getUserId()!)/wishlist/check/"
            let query = productIds.joined(separator: ",")
            url.append(query)
            return url
        case let .setWishlist(productId), let .unsetWishlist(productId):
            let userManager = UserAuthentificationManager()
            return "/users/\(userManager.getUserId()!)/wishlist/\(productId)/v1.1"
        case .getProductCampaignInforFor:
            return "os/v1/campaign/product/info"
        case let .requestOfficialStore(categoryId):
            return "os/api/v1/brands/category/ios/\(categoryId)"
        case .requestOfficialStoreHomePage:
            return "/os/api/v2/brands/list/widget/ios"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getProductWishStatus, .requestOfficialStore, .requestOfficialStoreHomePage: return .get
        case .setWishlist: return .post
        case .unsetWishlist: return .delete
        case .getProductCampaignInforFor: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getProductCampaignInforFor(productIds): return [
                    "pid":productIds
                    ]
        case .requestOfficialStore: return nil
        case .requestOfficialStoreHomePage: return ["device":"ios"]
        default: return [:]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
            case .requestOfficialStore: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
