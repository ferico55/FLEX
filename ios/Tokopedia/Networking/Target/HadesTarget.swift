//
//  HadesTarget.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

import Moya

class HadesProvider: RxMoyaProvider<HadesTarget> {
    
    init() {
        super.init(endpointClosure: HadesProvider.endpointClosure,
                   manager: DefaultAlamofireManager.sharedManager,
                   plugins: [NetworkLoggerPlugin(verbose: true),NetworkPlugin()])
    }
    
    private static func endpointClosure(target: HadesTarget) -> Endpoint<HadesTarget> {
        return NetworkProvider.defaultEndpointCreator(for: target)
    }
    
}

enum HadesTarget{
    case getCategoryIntermediary(forCategoryID:String)
    case getNavigationCategory(categoryId: String, root: Bool) //if root true then API will give all the root category, this will going true if user hit API directly from category result controller
    case getFilterCategories(categoryId: String)
}

extension HadesTarget : TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.hadesUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case let .getCategoryIntermediary(categoryID):
            return "/v1/categories/\(categoryID)/detail"
        case let .getNavigationCategory(categoryId, _):
            return "/v1/category_layout/\(categoryId)"
        case let .getFilterCategories(categoryID):
            var path : String = "/v1/categories"
            if Int(categoryID) != 0  && Int(categoryID) != nil {
                path = "/v1/categories/\(categoryID)"
            }
            return path
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getCategoryIntermediary:
            return .get
        case .getNavigationCategory:
            return .get
        case .getFilterCategories:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .getCategoryIntermediary :
            return [:]
        case let .getNavigationCategory(_, root) :
            return root ? ["type" : "root"] : [:]
        case .getFilterCategories :
            return ["filter":"type==tree"]
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
