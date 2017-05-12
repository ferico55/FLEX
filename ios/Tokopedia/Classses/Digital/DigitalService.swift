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
    
    func purchase(
        from viewController: UIViewController,
        withProductId productId: String,
        categoryId: String,
        inputFields: [String: String],
        instantPaymentEnabled: Bool,
        onNavigateToCart: @escaping () -> Void,
        onNeedLoading: @escaping () -> Void = {}
    ) -> Observable<Void> {
        
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
                        instantCheckout: instantPaymentEnabled
                    ))
            }
            .mapJSON() // TODO: use proper mapping
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
            .do(onError: { _ in
                _ = viewController.navigationController?.popToViewController(viewController, animated: true)
            })
            .flatMap { () -> Observable<DigitalCartPayment> in
                if instantPaymentEnabled {
                    onNeedLoading()
                    
                    return self.cart(categoryId: categoryId) // FIXME: reference cycle
                        .flatMap { cartId -> Observable<Response> in
                            onNeedLoading()
                            
                            return DigitalProvider()
                                .request(.payment(voucherCode: "", transactionAmount: 0, transactionId: cartId))
                        }
                        .map(to: DigitalCartPayment.self)
                        .map { cartPayment in
                            if let errorMessage = cartPayment.errorMessage  {                                                                throw errorMessage
                            }
                            return cartPayment
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
                            return cartPayment
                        }
                }
            }.map { cartPayment in
                onNavigateToCart()

                let webView = WebViewController()
                webView.hidesBottomBarWhenPushed = true
                webView.strURL = cartPayment.redirectUrl
                webView.strQuery = cartPayment.queryString
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
        return DigitalProvider()
            .request(.getCart(categoryId))
            .map(to: DigitalCart.self)
            .map { $0.cartId }

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
            sqObject.name = userName
            
            let securityViewController = SecurityQuestionViewController(securityQuestionObject: sqObject)
            securityViewController.hidesBottomBarWhenPushed = true
            securityViewController.questionType1 = "0"
            securityViewController.questionType2 = "2"
            securityViewController.successAnswerCallback = { _ in
                observer.onNext()
                observer.onCompleted()
            }
            
            viewController.present(UINavigationController(rootViewController: securityViewController), animated: true, completion: nil)
            
            return Disposables.create()
        }
        .flatMap { () -> Observable<Void> in
            DigitalProvider()
                .request(.otpSuccess(cartId))
                .map { _ in return }
        }
        .do(
            // TODO: try to use onCompleted
            onNext: {
                viewController.dismiss(animated: true, completion: nil)
            },
            onError: { _ in
                viewController.dismiss(animated: true, completion: nil)
            }
        )
        
    }
}
