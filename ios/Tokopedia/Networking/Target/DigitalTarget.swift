//
//  DigitalProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import AdSupport
import AppsFlyer
import Moya
import MoyaUnbox

private let userAgent = "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"

internal class DigitalProvider: NetworkProvider<DigitalTarget> {
    
    internal init() {
        super.init(endpointClosure: DigitalProvider.endpointClosure)
    }
    
    fileprivate class func endpointClosure(for target: DigitalTarget) -> Endpoint<DigitalTarget> {
        let userId = UserAuthentificationManager().getUserId()!
        
        var headers = target.method == .get || target.method == .delete ? [:] : [
            "X-Tkpd-UserId": userId,
            "Content-Type": "application/json",
            "Idempotency-Key": UUID().uuidString,
        ]
        let deviceIdentifier = DeviceIdentifier.deviceId
        headers["X-GA-ID"] = deviceIdentifier
        return NetworkProvider.defaultEndpointCreator(for: target)
            .adding(
                httpHeaderFields: headers
        )
    }
}

internal enum DigitalTarget {
    case addToCart(withProductId: String, inputFields: [String: String], instantCheckout: Bool)
    case payment(voucherCode: String, transactionAmount: Double, transactionId: String)
    case category(String)
    case voucher(categoryId: String, voucherCode: String)
    case otpSuccess(String)
    case getCart(String)
    case lastOrder(String)
    case deleteCart(String)
    case favourite(category: String, operatorID: String, clientNumber: String, productID: String)
    case cancelVoucher()
}

extension DigitalTarget: TargetType {
    
    /// The target's base `URL`.
    internal var baseURL: URL { return URL(string: NSString.pulsaApiUrl())! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    internal var path: String {
        switch self {
        case .addToCart: return "/v1.4/cart"
        case .payment: return "/v1.4/checkout"
        case let .category(categoryId): return "/v1.4/category/\(categoryId)"
        case .voucher: return "/v1.4/voucher/check"
        case .otpSuccess: return "/v1.4/cart/otp-success"
        case .getCart: return "/v1.4/cart"
        case .lastOrder: return "/v1.4/last-order"
        case .deleteCart: return "/v1.4/cart"
        case .favourite : return "/v1.4/favorite/list"
        case .cancelVoucher: return "/v1.4/voucher/cancel"
        }
    }
    
    /// The HTTP method used in the request.
    internal var method: Moya.Method {
        switch self {
        case .addToCart, .payment, .cancelVoucher: return .post
        case .category, .voucher, .getCart, .lastOrder, .favourite: return .get
        case .otpSuccess: return .patch
        case .deleteCart: return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    internal var parameters: [String: Any]? {
        let userManager = UserAuthentificationManager()
        
        switch self {
        case let .addToCart(productId, inputFields, instantCheckout):
            let fields = inputFields.map { key, value in
                return ["name": key, "value": value]
            }
            
            return [
                "data": [
                    "type": "add_cart",
                    "attributes": [
                        "product_id": Int(productId)!,
                        "device_id": 7,
                        "instant_checkout": instantCheckout,
                        "ip_address": getIFAddresses(),
                        "access_token": "",
                        "wallet_refresh_token": "",
                        "user_agent": userAgent,
                        "show_subscribe_flag": true,
                        "fields": fields,
                        "is_thankyou_native_new": true,
                        "identifier": [
                            "user_id": userManager.getUserId(),
                            "device_token": userManager.getMyDeviceToken(),
                            "os_type": "2"
                        ]
                    ]
                ]
            ]
            
        case let .otpSuccess(cartId):
            return [
                "data": [
                    "type": "cart",
                    "id": cartId,
                    "attributes": [
                        "ip_address": getIFAddresses(),
                        "user_agent": userAgent,
                        "identifier": [
                            "user_id": userManager.getUserId(),
                            "device_token": userManager.getMyDeviceToken(),
                            "os_type": "2"
                        ]
                    ]
                ]
            ]
            
        case let .payment(voucherCode, transactionAmount, transactionId):
            let tracker = GAI.sharedInstance().tracker(withTrackingId: "UA-9801603-10")
            let clientID = tracker?.get(kGAIClientId) ?? ""
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            let appsflyerID = AppsFlyerTracker.shared().appsFlyerDevKey ?? ""
            debugPrint("appsflyerID " + appsflyerID)
            let bundleID = Bundle.main.bundleIdentifier ?? "com.tokopedia.Tokopedia"
            return [
                "data": [
                    "type": "checkout",
                    "attributes": [
                        "device_id": 7,
                        "ip_address": getIFAddresses(),
                        "access_token": "",
                        "wallet_refresh_token": "",
                        "user_agent": userAgent,
                        "voucher_code": voucherCode,
                        "transaction_amount": transactionAmount,
                        "client_id": clientID,
                        "appsflyer": [
                            "appsflyer_id": appsflyerID,
                            "device_id": idfa,
                            "bundle_id": bundleID
                        ],
                        "identifier": [
                            "user_id": userManager.getUserId(),
                            "device_token": userManager.getMyDeviceToken(),
                            "os_type": "2"
                        ]
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
        case let .voucher(categoryId, voucherCode):
            return [
                "category_id": categoryId,
                "voucher_code": voucherCode
            ]
        case let .getCart(categoryId) :
            return ["category_id": categoryId]
        case let .lastOrder(categoryId) :
            return ["category_id": categoryId]
        case let .deleteCart(categoryId):
            return ["category_id": categoryId]
        case let .favourite(categoryId, operatorID, clientNumber, productID) :
            return [
                "category_id": categoryId,
                "operator_id": operatorID,
                "client_number": clientNumber,
                "product_id": productID,
                "sort": "label"
            ]
        case let .cancelVoucher:
            return [
                "data": [
                    "type": "cancel_voucher",
                    "attributes": [
                        "identifier": [
                            "user_id": userManager.getUserId(),
                            "device_token": userManager.getMyDeviceToken(),
                            "os_type": "2"
                        ]
                    ]
                ]
            ]
        default: return [:]
        }
        
    }
    
    /// The method used for parameter encoding.
    internal var parameterEncoding: ParameterEncoding {
        switch self {
        case .addToCart, .otpSuccess, .payment, .cancelVoucher: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    internal var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
    
    /// The type of HTTP task to be performed.
    internal var task: Task { return .request }
    
}

internal func getIFAddresses() -> String {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return "127.0.0.1" }
    guard let firstAddr = ifaddr else { return "127.0.0.1" }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        var addr = ptr.pointee.ifa_addr.pointee
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
            if addr.sa_family == UInt8(AF_INET) {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(
                    &addr,
                    socklen_t(addr.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    socklen_t(0),
                    NI_NUMERICHOST
                ) == 0 {
                    let address = String(cString: hostname)
                    addresses.append(address)
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return addresses.first ?? "127.0.0.1"
}
