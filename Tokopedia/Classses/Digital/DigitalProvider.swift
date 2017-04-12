//
//  DigitalProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox

class DigitalProvider: RxMoyaProvider<DigitalTarget> {
    init() {
        super.init(endpointClosure: DigitalProvider.endpointClosure)
    }
    
    private static func endpointClosure(service: DigitalTarget) -> Endpoint<DigitalTarget> {
        let hmac = TkpdHMAC()
        hmac.signature(
            withBaseUrl: service.baseURL.absoluteString,
            method: service.method.rawValue,
            path: service.path,
            json: service.parameters)
        
        let appVersion = UIApplication.getAppVersionString()
        
        let userId = UserAuthentificationManager().getUserId()!
        
        var headers = [
            "Accept": "application/json",
            "X-APP-VERSION": appVersion,
            "X-Device": "ios-\(appVersion)",
            "Accept-Language": "id-ID",
            "Accept-Encoding": "gzip",
            "X-User-ID": userId,
            "X-Tkpd-UserId": userId,
            "Idempotency-Key": UUID().uuidString
        ]
        
        hmac.authorizedHeaders().forEach { key, value in
            headers[key] = value
        }
        
        headers["Content-Type"] = "application/json"
        
        return Endpoint<DigitalTarget>(
            url: service.baseURL.appendingPathComponent(service.path).absoluteString,
            sampleResponseClosure: { .networkResponse(200, service.sampleData) },
            method: service.method,
            parameters: service.parameters,
            parameterEncoding: service.parameterEncoding,
            httpHeaderFields: headers
        )
    }
    
    
}

enum DigitalTarget {
    case addToCart(withProductId: String, inputFields: [String: String], instantCheckout: Bool)
    case payment(voucherCode:String, transactionAmount:Double, transactionId:String)
    case category(String)
    case otpSuccess(String)
}

extension DigitalTarget: TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: NSString.pulsaApiUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .addToCart: return "/v1.3/cart"
        case .payment: return "/v1.3/checkout"
        case let .category(categoryId): return "/v1.3/category/\(categoryId)"
        case .otpSuccess: return "/v1.3/cart/otp-success"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .addToCart: return .post
        case .payment: return .post
        case .category: return .get
        case .otpSuccess: return .patch
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case let .addToCart(productId, inputFields, instantCheckout):
            let fields = inputFields.map { key, value in
                return ["name": key, "value": value]
            }
            
            return [
                "data": [
                    "type":"add_cart",
                    "attributes": [
                        "product_id": Int(productId)!,
                        "device_id": 7,
                        "instant_checkout": instantCheckout,
                        "ip_address": getIFAddresses(),
                        "access_token": "",
                        "wallet_refresh_token": "",
                        "user_agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:51.0) Gecko/20100101 Firefox/51.0",
                        "fields": fields
                    ]
                ]
            ]
            
        case let .otpSuccess(cartId):
            return [
                "data": [
                    "type": "cart",
                    "id": cartId,
                    "attributes": [
                        "ip_address": "127.0.0.1",
                        "user_agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:51.0) Gecko/20100101 Firefox/51.0"
                    ]
                ]
            ]
            
        case let .payment(voucherCode, transactionAmount, transactionId):
            return [
                "data": [
                    "type":"checkout",
                    "attributes": [
                        "device_id": 7,
                        "ip_address": getIFAddresses(),
                        "access_token": "",
                        "wallet_refresh_token": "",
                        "user_agent": "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5",
                        "voucher_code":voucherCode,
                        "transaction_amount":transactionAmount
                    ],
                    "relationships": [
                        "cart": [
                            "data": [
                                "type": "cart",
                                "id": transactionId
                            ]
                        ]
                    ]
                ]
            ]
        default: return [:]
        }
        
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .addToCart, .otpSuccess, .payment: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
    
    
}

func getIFAddresses() -> String {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return "127.0.0.1" }
    guard let firstAddr = ifaddr else { return "127.0.0.1" }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        var addr = ptr.pointee.ifa_addr.pointee
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
            if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                    let address = String(cString: hostname)
                    addresses.append(address)
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return addresses.first ?? "127.0.0.1"
}
