//
//  AceProvider.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import MoyaUnbox
import Moya

enum AceTarget{
    case getHotList(forCategory: String, perPage:Int)
    case getOtherProduct(withProductID: String, shopID: String)
    case searchProduct(selectedCategoryString: String, rows: String, start: String, q: String, uniqueID: String, source:String, departmentName:String)
    case searchProductWith(params:[String:Any], path:String)
}

extension AceTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.aceUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
            case .getHotList: return "/hoth/hotlist/v1/category"
            case .getOtherProduct: return "/search/v2.3/product"
            case .searchProduct: return "/search/v2.5/product"
            case let .searchProductWith(_, path): return path
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getHotList: return .get
        case .getOtherProduct: return .get
        case .searchProduct: return .get
        case .searchProductWith: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .getHotList(category, perPage) :
            return [
                "categories" : category,
                "perPage" : perPage
            ]
        case let .getOtherProduct(productID, shopID) :
            return [
                "shop_id" : shopID,
                "device" : "ios",
                "-id" : productID,
                "source":"other_product"
            ]
        case let .searchProduct(selectedCategoryString, rows, start, q, uniqueID, source, departmentName) :
            return [
                "device":"ios",
                "sc":selectedCategoryString,
                "q": q,
                "rows": rows,
                "start": start,
                "breadcrumb": "true",
                "source":source,
                "unique_id":uniqueID,
                "department_name": departmentName
            ]
        case let .searchProductWith(params, _): return params
        }
        
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
}
