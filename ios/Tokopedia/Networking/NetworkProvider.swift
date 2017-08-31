//
//  NetworkProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import RxSwift

extension Notification.Name {
    static let forceLogout = Notification.Name("NOTIFICATION_FORCE_LOGOUT")
}

private enum ResponseType: String {
    case normal = "OK"
    case maintenance = "UNDER_MAINTENANCE"
    case tooManyRequests = "TOO_MANY_REQUEST"
    case requestDenied = "REQUEST_DENIED"
    
    init(response: Response) {
        guard let json = try? response.mapJSON() as? [String: Any],
            let status = json?["status"] as? String,
            let responseType = ResponseType(rawValue: status)
        else {
            self = .normal
            return
        }
        
        self = responseType
    }
}

class NetworkProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    override init(
        endpointClosure: @escaping EndpointClosure = NetworkProvider.defaultEndpointCreator,
        requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
        stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
        manager: Manager = RxMoyaProvider<Target>.defaultAlamofireManager(),
        plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true)],
        trackInflights: Bool = false
    ) {
        
        super.init(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            manager: manager,
            plugins: plugins,
            trackInflights: trackInflights
        )
    }
    
    final class func defaultEndpointCreator(for target: Target) -> Endpoint<Target> {
        let hmac = TkpdHMAC()
        let appVersion = UIApplication.getAppVersionString()
        
        let headers = [
            "Accept": "application/json",
            "X-APP-VERSION": appVersion,
            "X-Device": "ios-\(appVersion)",
            "Accept-Language": "id-ID",
            "Accept-Encoding": "gzip",
            "X-Tkpd-UserId": UserAuthentificationManager().getUserId()!
        ]
        
        let parameters = !(target.parameterEncoding is Moya.JSONEncoding) ? (target.parameters as! NSDictionary).autoParameters() : target.parameters
        
        if !(target.parameterEncoding is Moya.JSONEncoding) {
            //TODO:: due to different signature creation of mojito, we need to handle it separately
            if(target.baseURL == URL(string: NSString.mojitoUrl())) {
                hmac.signature(withBaseUrl: target.baseURL.absoluteString,
                               method: target.method.rawValue,
                               path: target.path,
                               parameter: parameters)
            } else {
                hmac.signature(
                    withBaseUrlPulsa: target.baseURL.absoluteString,
                    method: target.method.rawValue,
                    path: target.path,
                    parameter: parameters
                )
            }
            
        } else {
            hmac.signature(
                withBaseUrl: target.baseURL.absoluteString,
                method: target.method.rawValue,
                path: target.path,
                json: target.parameters
            )
        }
        
        return Endpoint<Target>(
            url: target.baseURL.appendingPathComponent(target.path).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: parameters,
            parameterEncoding: target.parameterEncoding,
            httpHeaderFields: headers
        ).adding(httpHeaderFields: hmac.authorizedHeaders())
    }
    
    override func request(_ token: Target) -> Observable<Response> {
        return super.request(token)
            .do(onNext: { response in
                switch ResponseType(response: response) {
                    
                case .maintenance, .tooManyRequests:
                    NavigateViewController.navigateToMaintenanceViewController()
                    
                case .requestDenied:
                    AuthenticationService().reloginAccount()
                    
                default: return
                    
                }
            })
            .flatMap { response -> Observable<Response> in
                ResponseType(response: response) == .normal ? .just(response) : .empty()
            }
    }
}
