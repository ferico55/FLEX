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
import SwiftyJSON

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
        guard let navigationController = viewController.navigationController else {
            fatalError("No Controller")
        }
        let viewController = navigationController.topViewController!
        
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
                    guard let navigationController = viewController.navigationController else {
                        fatalError("No Controller")
                    }
                    var viewControllers = navigationController.childViewControllers
                    
                    while viewControllers.last !== viewController {
                        _ = viewControllers.popLast()
                    }
                    
                    let cartViewController = DigitalCartViewController()
                    cartViewController.hidesBottomBarWhenPushed = true
                    cartViewController.categoryId = categoryId
                    
                    viewController.navigationController?.pushViewController(cartViewController, animated: true)
                    
                    return cartViewController.cartPayment
                        .map { cartPayment in
                            return cartPayment
                        }
                }
            }.map { cartPayment in
                onNavigateToCart()

                let webView = WebViewController()
                webView.navigationPivotVisible = false
                webView.hidesBottomBarWhenPushed = true
                webView.strURL = cartPayment.redirectUrl
                webView.strQuery = cartPayment.queryString
                webView.shouldAuthorizeRequest = false
                webView.strTitle = "Pembayaran"

                guard let navigationController = viewController.navigationController else {
                    return
                }
                var viewControllers = navigationController.childViewControllers
                
                //                while viewControllers.last !== viewController {
                //                    _ = viewControllers.popLast()
                //                }
                
                webView.onTapBackButton = { url in
                    if let paymentUrl = url?.absoluteString.contains("payment"), paymentUrl {
                        viewController.navigationController?.popViewController(animated: true)
                    } else {
                        viewController.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
                viewControllers.append(webView)
                
                webView.onTapLinkWithUrl = { url in
                    if let openThanksPage = url?.absoluteString.contains("/thanks"), openThanksPage {
                        guard let navigationController = viewController.navigationController else {
                            return
                        }
                        var viewControllers = navigationController.childViewControllers
                        
                        let vcs = Array(viewControllers[0...viewControllers.index(of: viewController)!]) + [webView]
                        viewController.navigationController?.setViewControllers(vcs, animated: false)
                    }
                    
                    if (url?.absoluteString == cartPayment.callbackUrlSuccess) {
                        viewController.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
                navigationController.setViewControllers(viewControllers, animated: true)
                
                return
            }
    }
    
    private func cart(categoryId: String) -> Observable<String> {
        return DigitalProvider()
            .request(.getCart(categoryId))
            .map(to: DigitalCart.self)
            .map { $0.cartId }

    }
    
    func lastOrder(categoryId:String) -> Observable<DigitalLastOrder> {
        return Observable.concat (
            getWSLastOrder(category: categoryId),
            getCacheLastOrder(category: categoryId),
            getDefaultLastOrder(category: categoryId)
            )
            .filter { $0 != nil }
            .take(1)
            .map{ $0! }
    }
    
    func getWSLastOrder (category: String) -> Observable<DigitalLastOrder?> {
        if (!UserAuthentificationManager().isLogin) {
            return Observable.empty()
        }
        
        return DigitalProvider()
            .request(.lastOrder(category))
            .mapJSON()
            .map { response in
                let result = JSON(response)
                if (category == result.dictionaryValue["data"]?.dictionaryValue["attributes"]?.dictionaryValue["category_id"]?.stringValue) {
                    return DigitalLastOrder.fromJSON((result.dictionaryValue["data"]?.dictionaryValue["attributes"]?.dictionaryObject)!)
                }
                return nil
        }
    }
    
    func getCacheLastOrder(category:String) -> Observable<DigitalLastOrder?> {
        return Observable.create{ (observer) -> Disposable in
            let cache = PulsaCache()
            
            cache.loadLastOrder(categoryId: category, loadLastOrderCallBack: { (lastOrder) in
                observer.on(.next(lastOrder))
                observer.on(.completed)
            })
            
            return Disposables.create()
        }
    }
    
    func getDefaultLastOrder(category:String) -> Observable<DigitalLastOrder?> {
        return Observable.create { observer -> Disposable in
            let order:DigitalLastOrder = { () -> DigitalLastOrder in
                switch (category) {
                case "1", "2" : return DigitalLastOrder(categoryId: category, operatorId: nil, productId: nil, clientNumber: UserAuthentificationManager().getUserPhoneNumber())
                default:
                    return DigitalLastOrder(categoryId: category)
                }
            }()
            
            observer.on(.next(order))
            observer.on(.completed)
            
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
            sqObject.name = userName
            
            let securityViewController = SecurityQuestionViewController(securityQuestionObject: sqObject)
            securityViewController.hidesBottomBarWhenPushed = true
            securityViewController.questionType1 = "0"
            securityViewController.questionType2 = "2"
            securityViewController.successAnswerCallback = { _ in
                observer.onNext()
                observer.onCompleted()
            }
            
            let navigationController = UINavigationController(rootViewController: securityViewController)
            navigationController.setWhite()
            
            viewController.present(navigationController, animated: true, completion: nil)
            
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
