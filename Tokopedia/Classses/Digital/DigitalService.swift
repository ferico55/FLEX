//
//  DigitalService.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Unbox

class DigitalService {
    typealias UrlQueryPair = (String, String)
    
    func purchase(
        from viewController: UIViewController,
        withProductId productId: String,
        categoryId: String,
        inputFields: [String: String],
        instantPaymentEnabled: Bool,
        onNavigateToCart: @escaping () -> (),
        onNeedLoading: @escaping () -> () = {}) -> Observable<Void> {
        
        // prevent crash on home
        let viewController = viewController.navigationController!.topViewController!
        
        if !UserAuthentificationManager().isLogin {
            onNavigateToCart()
        }
        
        return AuthenticationService()
            .ensureLoggedIn(from: viewController)
            .flatMap { () -> Observable<Response> in
                onNeedLoading()
                
                return DigitalProvider()
                    .request(.addToCart(
                        withProductId: productId,
                        inputFields: inputFields,
                        instantCheckout: instantPaymentEnabled))
            }
            .mapJSON() //TODO: use proper mapping
            .flatMap { response -> Observable<Void> in
                onNavigateToCart()
                
                let result = response as! [String: Any]
                
                let unboxer = Unboxer(dictionary: result)
                
                if let _ = try? unboxer.unbox(keyPath: "data") as [String: Any] {
                    let needOtp = try! unboxer.unbox(keyPath: "data.attributes.need_otp") as Bool
                    let cartId = try! unboxer.unbox(keyPath: "data.id") as String
                    
                    return self.verifyOtp(from: viewController, needOtp: needOtp, cartId: cartId)
                } else {
                    let errorMessage = try! unboxer.unbox(keyPath: "errors.0.title") as String
                    
                    throw errorMessage
                }
            }
            .do(onError: { error in
                _ = viewController.navigationController?.popToViewController(viewController, animated: true)
            })
            .flatMap { () -> Observable<UrlQueryPair> in
                if instantPaymentEnabled {
                    onNeedLoading()
                    
                    return self.cart(categoryId: categoryId) //FIXME: reference cycle
                        .flatMap { cartId -> Observable<Response> in
                            onNeedLoading()
                            
                            return DigitalProvider()
                                .request(.payment(voucherCode: "", transactionAmount: 0, transactionId: cartId))
                        }
                        .mapJSON()
                        .map { json -> UrlQueryPair in
                            let unboxer = Unboxer(dictionary: json as! [String: Any])
                            
                            if let _ = try? unboxer.unbox(keyPath: "errors") as [Any] {
                                let errorMessage = try! unboxer.unbox(keyPath: "errors.0.title") as String
                                
                                throw errorMessage
                            }
                            
                            let url = try! unboxer.unbox(keyPath: "data.attributes.thanks_url") as String
                            
                            return (url, "")
                        }
                } else {
                    onNavigateToCart()
                    
                    var viewControllers = viewController.navigationController!.childViewControllers
                    
                    while viewControllers.last !== viewController {
                        _ = viewControllers.popLast()
                    }
                    
                    let cartViewController = DigitalCartViewController()
                    cartViewController.hidesBottomBarWhenPushed = true
                    cartViewController.categoryId = categoryId
                    
                    viewControllers.append(cartViewController)
                    viewController.navigationController?.setViewControllers(viewControllers, animated: true)
                    
                    return cartViewController.cartPayment
                        .map { cartPayment in
                            return (cartPayment.redirectUrl, cartPayment.queryString)
                        }
                }
            }.map { url, queryString in
                onNavigateToCart()
                
                let webView = WebViewController()
                webView.hidesBottomBarWhenPushed = true
                webView.strURL = url
                webView.strQuery = queryString
                webView.shouldAuthorizeRequest = false
                webView.strTitle = "Pembayaran"
                
                var viewControllers = viewController.navigationController!.childViewControllers
                
//                while viewControllers.last !== viewController {
//                    _ = viewControllers.popLast()
//                }
                
                viewControllers.append(webView)
                
                webView.onTapLinkWithUrl = { url in
                    if let openThanksPage = url?.absoluteString.contains("/thanks"), openThanksPage {
                        var viewControllers = viewController.navigationController!.childViewControllers
                        
                        let vcs = Array(viewControllers[0...viewControllers.index(of: viewController)!]) + [webView]
                        viewController.navigationController?.setViewControllers(vcs, animated: false)
                    }
                }
                
                viewController.navigationController!.setViewControllers(viewControllers, animated: true)
                
                return
            }
    }
    
    private func cart(categoryId: String) -> Observable<String> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let header = ["X-User-ID": UserAuthentificationManager().getUserId()!]
        let parameters = ["category_id": categoryId]
        
        return Observable.create { observer in
            
            networkManager.request(
                withBaseUrl: NSString.pulsaApiUrl(),
                path: "/v1.3/cart",
                method: .GET,
                header: header,
                parameter: parameters,
                mapping: JSONAPIResponse.mapping(),
                onSuccess: { mappingResult, operation in
                    let response = mappingResult.dictionary() as Dictionary
                    let json = response[""] as! JSONAPIResponse
                    
                    let cartId = json.data.id
                    
                    observer.onNext(cartId)
                },
                onFailure: { error in
                    observer.onError(NSError(domain: "domain", code: -999))
                }
            )
            
            return Disposables.create()
        }
    }
    
    private func verifyOtp(from viewController: UIViewController, needOtp: Bool, cartId: String) -> Observable<Void> {
        guard needOtp else {
            return Observable.create { observer in
                observer.onNext()
                
                return Disposables.create()
            }
        }
        
        return Observable.create { [weak self] observer in
            let auth = UserAuthentificationManager()
            let userId = auth.getUserId()!
            let deviceId = auth.getMyDeviceToken()
            let dict = auth.getUserLoginData()!
            let userName = dict["full_name"] as! String
            
            let oAuthToken = OAuthToken()
            oAuthToken.tokenType = dict["oAuthToken.tokenType"] as! String
            oAuthToken.accessToken = dict["oAuthToken.accessToken"] as! String
            
            let sqObject = SecurityQuestionObjects()
            sqObject.userID = userId
            sqObject.deviceID = deviceId
            sqObject.token = oAuthToken
            
            let securityViewController = SecurityQuestionViewController(securityQuestionObject: sqObject)
            securityViewController.hidesBottomBarWhenPushed = true
            securityViewController.questionType1 = "0"
            securityViewController.questionType2 = "2"
            securityViewController.successAnswerCallback =  { _ in
                observer.onNext()
                observer.onCompleted()
            }
            
            viewController.present(UINavigationController(rootViewController: securityViewController), animated: true, completion: nil)
            
            return Disposables.create()
            }.flatMap { () -> Observable<Void> in
                return DigitalProvider()
                    .request(.otpSuccess(cartId))
                    .map { _ in return }
        }
    }
}
