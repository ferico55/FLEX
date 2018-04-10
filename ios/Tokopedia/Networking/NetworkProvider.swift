//
//  NetworkProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Crashlytics
import FirebaseRemoteConfig
import Moya
import RxSwift
import UIKit

extension TargetType {
    internal func urlString() -> String? {
        if let request = try? MoyaProvider.defaultEndpointMapping(for: self).urlRequest, let url = request?.url {
            let key = url.absoluteString
            return key
        }
        
        return nil
    }
}

extension Notification.Name {
    internal static let forceLogout = Notification.Name("NOTIFICATION_FORCE_LOGOUT")
}

private enum ResponseType: String {
    case normal = "OK"
    case maintenance = "UNDER_MAINTENANCE"
    case tooManyRequests = "TOO_MANY_REQUEST"
    case requestDenied = "REQUEST_DENIED"
    case invalidRequest = "INVALID_REQUEST"
    case forbidden
    
    init(response: Response) {
        if response.statusCode == 403 {
            self = .forbidden
            return
        }
        
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

internal class NetworkProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    override internal init(
        endpointClosure: @escaping EndpointClosure = NetworkProvider.defaultEndpointCreator,
        requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
        stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
        manager: Manager = RxMoyaProvider<Target>.defaultAlamofireManager(),
        plugins: [PluginType] = [CrashlyticsPlugin()],
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
    
    final internal class func urlRequest(for target: Target) -> URLRequest? {
        let endpoint: Endpoint<Target> = NetworkProvider.defaultEndpointCreator(for: target)
        return endpoint.urlRequest
    }
    
    final internal class func defaultEndpointCreator(for target: Target) -> Endpoint<Target> {
        let hmac = TkpdHMAC()
        let appVersion = UIApplication.getAppVersionString()
        
        let headers = [
            "Accept": "application/json",
            "X-APP-VERSION": appVersion,
            "X-Device": "ios-\(appVersion)",
            "Accept-Language": "id-ID",
            "Accept-Encoding": "gzip",
            "X-Tkpd-UserId": UserAuthentificationManager().getUserId() ?? "0"
        ]
        
        let parameters = !(target.parameterEncoding is Moya.JSONEncoding) ? (target.parameters! as NSDictionary).autoParameters() : target.parameters
        
        if !(target.parameterEncoding is Moya.JSONEncoding) {
            hmac.signature(
                withBaseUrlPulsa: target.baseURL.absoluteString,
                method: target.method.rawValue,
                path: target.path,
                parameter: parameters
            )
            
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
    
    override internal func request(_ token: Target) -> Observable<Response> {
        var hasRetriedOnce = false
        
        return super.request(token)
            .do(onNext: { response in
                let type = ResponseType(response: response)
                switch type {
                case .maintenance, .tooManyRequests:
                    NavigateViewController.navigateToMaintenanceViewController()
                case .forbidden:
                    if RemoteConfig.remoteConfig().shouldShowForbiddenScreen {
                        UIApplication.topViewController()?.present(ForbiddenViewController(), animated: true)
                    }
                default: return
                }
            })
            .flatMap({ (response) -> Observable<Response> in
                let type = ResponseType(response: response)
                if type == .requestDenied || type == .invalidRequest, let urlString = response.request?.url?.absoluteStringByTrimmingQuery() {
                    if !hasRetriedOnce {
                        hasRetriedOnce = true
                        return self.handleErrorRequest(responseType: ResponseType(response: response), urlString: urlString)
                    } else {
                        LogEntriesHelper.logForceLogout(lastURL: urlString)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_FORCE_LOGOUT"), object: nil)
                        return .empty()
                    }
                }
                
                return ResponseType(response: response) == .normal ? .just(response) : .empty()
                
            })
            .retry(2)
    }
    
    private func handleErrorRequest(responseType: ResponseType, urlString: String) -> Observable<Response> {
        return Observable.create({ observer -> Disposable in
            RequestErrorHandler.handleForceLogout(
                responseType: responseType.rawValue,
                urlString: urlString,
                onSuccess: {
                    observer.onError(RequestError.networkError as Swift.Error)
                }
            )
            return Disposables.create()
        })
    }
    
}
