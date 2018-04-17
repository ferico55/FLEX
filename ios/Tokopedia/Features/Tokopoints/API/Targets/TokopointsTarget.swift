//
//  TokopointsTarget.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

@objc internal enum PromoServiceType: Int {
    case marketplace
    case digital
}

internal let type = [
    PromoServiceType.marketplace: "marketplace",
    PromoServiceType.digital: "digital"
]

internal enum TokopointsTarget {
    case getDrawerData
    case getCoupons(serviceType: PromoServiceType, productId: String?, categoryId: String?, page: Int64)
    case geocode(address: String?, latitudeLongitude: String?)
    case downloadFile(url: String, key: String?)
    
    internal var localLocation: URL {
        switch self {
        case let .downloadFile(url, key):
            let fileKey = key ?? url.toMD5()
            let directory = FileSystem.downloadDirectory.appendingPathComponent(fileKey)
            return directory
        default:
            return URL(string: "")!
        }
    }
    
    internal var downloadDestination: DownloadDestination {
        return { _, _ in
            return (self.localLocation, [.removePreviousFile, .createIntermediateDirectories])
        }
    }
}

extension TokopointsTarget: TargetType {
    /// The target's base `URL`.
    internal var baseURL: URL {
        switch self {
        case let .downloadFile(url, _):
            if let scheme = URL(string: url)?.scheme, let host = URL(string: url)?.host {
                return URL(string: scheme + "://" + host)!
            }
            return URL(string: NSString.tokopointsUrl())!
        default:
            return URL(string: NSString.tokopointsUrl())!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    internal var path: String {
        switch self {
        case .getDrawerData: return "/tokopoints/api/v1/points/drawer"
        case .getCoupons: return "/tokopoints/api/v1/coupon/list"
        case .geocode: return "/maps/geocode"
        case let .downloadFile(url, _): return URL(string: url)!.path
        }
    }
    
    /// The HTTP method used in the request.
    internal var method: Moya.Method {
        switch self {
        case .getDrawerData: return .get
        case .getCoupons: return .get
        case .geocode: return .get
        case .downloadFile: return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    internal var parameters: [String: Any]? {
        let userManager = UserAuthentificationManager()
        
        switch self {
        case .getDrawerData:
            let userManager = UserAuthentificationManager()
            return ["user_id": userManager.getUserId()]
        case let .getCoupons(serviceType, productId, categoryId, page):
            var params: [String: Any] = [
                "user_id": userManager.getUserId(),
                "page": page,
                "type": type[serviceType] ?? "" as Any
            ]
            if let productId = productId {
                params["product_id"] = productId
            }
            if let categoryId = categoryId {
                params["category_id"] = categoryId
            }
            return params
        case let .geocode(address, latitudeLongitude):
            var params: [String: Any] = [:]
            if let address = address {
                params["address"] = address
            }
            if let latitudeLongitude = latitudeLongitude {
                params["latlng"] = latitudeLongitude
            }
            return params
        default:
            return [:]
        }
    }
    
    /// The method used for parameter encoding.
    internal var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    internal var sampleData: Data {
        return "{\"data\": 123 }".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    internal var task: Task {
        switch self {
        case .downloadFile:
            return .download(DownloadType.request(downloadDestination))
        default:
            return .request
        }
    }
}

internal class FileSystem {
    internal static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    internal static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("Downloads/")
        return directory
    }()
    
}
