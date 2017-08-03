//
//  V4Target.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

enum V4Target {
    case getProductDetail(withProductId: String?, productName: String?, shopName: String?)
    case setFavorite(forShopId: String, adKey: String?)
    case moveToWarehouse(withProductId: String)
    case moveToEtalase(withProductId: String, etalaseId: String, etalaseName: String)
    case getProductsForShop(parameters: [String:Any], isAce: Bool)
}

extension V4Target: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        switch self {
        case let .getProductsForShop(_, isAce):
            let baseUrl: String = isAce ? NSString.aceUrl() : NSString.tomeUrl()
            return URL(string: baseUrl)!
        default : return URL(string: NSString.v4Url())!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getProductDetail: return "/v4/product/get_detail.pl"
        case .setFavorite: return "/v4/action/favorite-shop/fav_shop.pl"
        case .moveToWarehouse: return "/v4/action/product/move_to_warehouse.pl"
        case .moveToEtalase: return "/v4/action/product/edit_etalase.pl"
        case .getProductsForShop: return "/v1/web-service/shop/get_shop_product"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getProductDetail, .getProductsForShop: return .get
        case .setFavorite, .moveToWarehouse, .moveToEtalase: return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getProductDetail(productId, productName, shopName):
            return ["product_id": productId ?? "",
                    "product_key": productName ?? "",
                    "shop_domain": shopName ?? ""]
            
        case let .setFavorite(shopId, adKey):
            return ["shop_id": shopId, "ad_key": adKey ?? ""]
            
        case let .moveToWarehouse(productId):
            return ["product_id": productId]
            
        case let .moveToEtalase(productId, etalaseId, etalaseName):
            return ["product_id": productId, "product_etalase_id": etalaseId, "product_etalase_name": etalaseName]
        case let .getProductsForShop(parameters, _) :
            return parameters
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
