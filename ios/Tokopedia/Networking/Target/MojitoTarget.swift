//
//  MojitoProvider.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

internal class MojitoProvider: NetworkProvider<MojitoTarget> {
    internal init() {
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

internal enum MojitoTarget{
    case getProductWishStatus(productIds: [String])
    case setWishlist(withProductId: String)
    case unsetWishlist(withProductId: String)
    case getProductCampaignInfo(withProductIds:String)
    case requestOfficialStore(categoryId: String)
    case requestOfficialStoreHomePage
    case setRecentView(productID: String)
}

extension MojitoTarget : TargetType {
    /// The target's base `URL`.
    internal var baseURL: URL { return URL(string: NSString.mojitoUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    internal var path: String {
        switch self {
        case let .getProductWishStatus(productIds):
            let userManager = UserAuthentificationManager()
            var url = "/v1/users/\(userManager.getUserId()!)/wishlist/check/"
            let query = productIds.joined(separator: ",")
            url.append(query)
            return url
        case .setWishlist, .unsetWishlist:
            return "/wishlist/v1.2"
        case .getProductCampaignInfo:
            return "os/v1/campaign/product/info"
        case let .requestOfficialStore(categoryId):
            return "os/api/v1/brands/category/ios/\(categoryId)"
        case .requestOfficialStoreHomePage:
            return "/os/api/v2/brands/list/widget/ios"
        case .setRecentView:
            return "/recentview/pixel.gif"
        }
    }
    
    /// The HTTP method used in the request.
    internal var method: Moya.Method {
        switch self {
        case .getProductWishStatus, .requestOfficialStore, .requestOfficialStoreHomePage, .getProductCampaignInfo, .setRecentView: return .get
        case .setWishlist: return .post
        case .unsetWishlist: return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    internal var parameters: [String: Any]? {
        let userManager = UserAuthentificationManager()
        
        switch self {
        case let .setWishlist(productId), let .unsetWishlist(productId): return ["product_id" : productId, "user_id" : userManager.getUserId()!]
        case let .getProductCampaignInfo(productIds): return [ "pid":productIds ]
        case .requestOfficialStore: return nil
        case .requestOfficialStoreHomePage: return ["device":"ios"]
        case let .setRecentView(productID): return ["product_id" : productID, "user_id" : userManager.getUserId()!]
        default: return [:]
        }
    }
    
    /// The method used for parameter encoding.
    internal var parameterEncoding: ParameterEncoding {
        switch self {
        case .requestOfficialStore : return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    internal var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    internal var task: Task { return .request }
}
