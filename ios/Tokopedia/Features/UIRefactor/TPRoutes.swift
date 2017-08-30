//
//  TPRoutes.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import JLRoutes
import RxSwift

class TPRoutes: NSObject {
    
    static func configureRoutes() {
        let navigator = NavigateViewController()
        
        // applinks..
        // shop
        JLRoutes.global().addRoute("/pop-to-root") { (_: [String: Any]!) -> Bool in
            UIApplication.topViewController()?.navigationController?.popToRootViewController(animated: true)
            return true
        }
        
        JLRoutes.global().addRoute("/shop/:shopId") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            navigator.navigateToShop(from: UIApplication.topViewController(), withShopID: shopId)
            return true
        }
        
        JLRoutes.global().addRoute("/shop/:shopId/etalase/:etalaseId") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            let etalaseId = params["etalaseId"] as! String
            guard let keyword = params["search"] as? String else {
                return false
            }
            guard let by = params["sort"] as? String else {
                return false
            }
            navigator.navigateToShop(from: UIApplication.topViewController(), withShopID: shopId, withEtalaseId: etalaseId, search: keyword, sort: by)
            return true
        }
        
        JLRoutes.global().addRoute("/shop/:shopId/etalase/:etalaseId") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            let etalaseId = params["etalaseId"] as! String
            navigator.navigateToShop(from: UIApplication.topViewController(), withShopID: shopId, withEtalaseId: etalaseId)
            return true
        }
        
        JLRoutes.global().addRoute("shop/:shopId/info") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            navigator.navigateToShopInfo(from: UIApplication.topViewController(), withShopID: shopId)
            return true
        }
        
        JLRoutes.global().addRoute("shop/:shopId/talk") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            navigator.navigateToShopTalk(from: UIApplication.topViewController(), withShopID: shopId)
            return true
        }
        
        JLRoutes.global().addRoute("shop/:shopId/review") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            navigator.navigateToShopReview(from: UIApplication.topViewController(), withShopID: shopId)
            return true
        }
        
        JLRoutes.global().addRoute("shop/:shopId/note") { (params: [String: Any]!) -> Bool in
            let shopId = params["shopId"] as! String
            navigator.navigateToShopNote(from: UIApplication.topViewController(), withShopID: shopId)
            return true
        }
        
        // inbox message
        JLRoutes.global().addRoute("/message") { (_: [String: Any]!) -> Bool in
            navigator.navigateToInboxMessage(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("/message/:messageId") { (params: [String: Any]!) -> Bool in
            let messageId = params["messageId"] as! String
            navigator.navigateToInboxMessage(from: UIApplication.topViewController(), withMessageId: messageId)
            return true
        }
        
        // inbox talk
        JLRoutes.global().addRoute("/talk") { (_: [String: Any]!) -> Bool in
            navigator.navigateToInboxTalk(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("/talk/:talkId") { (params: [String: Any]!) -> Bool in
            let talkId = params["talkId"] as! String
            navigator.navigateToInboxTalk(from: UIApplication.topViewController(), withTalkId: talkId)
            return true
        }
        
        //        JLRoutes.global().addRoute("/talk/:talkId") { (params: [String : Any]!) -> Bool in
        //            let talkId = params["talkId"] as! String
        //            let shopId = params["shop_id"] as! String
        //            navigator.navigateToInboxTalk(from: UIApplication.topViewController(), withTalkId:talkId, withShopId:shopId)
        //            return true
        //        }
        
        // inbox review
        JLRoutes.global().addRoute("/review") { (_: [String: Any]!) -> Bool in
            navigator.navigateToInboxReview(from: UIApplication.topViewController())
            return true
        }
        
        // product
        JLRoutes.global().addRoute("/product/:productId") { (params: [String: Any]!) -> Bool in
            let productId = params["productId"] as! String
            NavigateViewController.navigateToProduct(from: UIApplication.topViewController(), withProductID: productId, andName: "", andPrice: "", andImageURL: "", andShopName: "")
            return true
        }
        
        JLRoutes.global().addRoute("product/:productId/review") { (params: [String: Any]!) -> Bool in
            let productId = params["productId"] as! String
            navigator.navigateToProductReview(from: UIApplication.topViewController(), withProductID: productId)
            return true
        }
        
        // cart
        JLRoutes.global().addRoute("cart") { (_: [String: Any]!) -> Bool in
            navigator.navigateToCart(from: UIApplication.topViewController())
            return true
        }
        
        // seller transactions
        JLRoutes.global().addRoute("seller/new-order") { (_: [String: Any]!) -> Bool in
            navigator.navigateToSellerNewOrder(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("seller/shipment") { (_: [String: Any]!) -> Bool in
            navigator.navigateToSellerShipment(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("seller/status") { (_: [String: Any]!) -> Bool in
            navigator.navigateToSellerShipmentStatus(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("seller/history") { (_: [String: Any]!) -> Bool in
            navigator.navigateToSellerHistory(from: UIApplication.topViewController())
            return true
        }
        
        // buyer transactions
        JLRoutes.global().addRoute("buyer/payment") { (_: [String: Any]!) -> Bool in
            navigator.navigateToBuyerPayment(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("buyer/order") { (_: [String: Any]!) -> Bool in
            navigator.navigateToBuyerOrder(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("buyer/shipping-confirm") { (_: [String: Any]!) -> Bool in
            navigator.navigateToBuyerShippingConf(from: UIApplication.topViewController())
            return true
        }
        
        JLRoutes.global().addRoute("buyer/history") { (_: [String: Any]!) -> Bool in
            navigator.navigateToBuyerHistory(from: UIApplication.topViewController())
            return true
        }
        
        // discovery
        JLRoutes.global().addRoute("hot") { (_: [String: Any]!) -> Bool in
            navigator.navigateToHotList(from: UIApplication.topViewController())
            return true
        }
        // ..applinks
        
        // Feed Detail
        JLRoutes.global().addRoute("/feedcommunicationdetail/:feedID") { (params: [String: Any]!) -> Bool in
            let feedCardID = params["feedID"] as! String
            navigator.navigateToFeedDetail(from: UIApplication.topViewController(), withFeedCardID: feedCardID)
            return true
        }
        
        // Resolution Detail
        JLRoutes.global().addRoute("/resolution/:resolutionId") { (params: [String: Any]!) -> Bool in
            let resolutionId = params["resolutionId"] as! String
            let controller = ResolutionWebViewController(resolutionId: resolutionId)
            UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
            return true
        }
        
        JLRoutes.global().unmatchedURLHandler = { _, url, _ in
            self.openWebView(url!)
        }
        
        JLRoutes.global().addRoute("/tokocash") { _ in
            let viewController = DigitalCategoryMenuViewController(categoryId: "103")
            
            UIApplication.topViewController()?
                .navigationController?
                .pushViewController(viewController, animated: false)
            return true
        }
        
        JLRoutes.global().addRoute("/digital") { params in
            let viewController = DigitalCategoryListViewController()
            viewController.title = "Pilih Produk"
            viewController.hidesBottomBarWhenPushed = true
            
            UIApplication.topViewController()?
                .navigationController?
                .pushViewController(viewController, animated: true)
            return true
        }
        
        JLRoutes.global().addRoute("/digital/form") { params in
            let viewController = DigitalCategoryMenuViewController(categoryId: params["category_id"] as! String)
            
            UIApplication.topViewController()?
                .navigationController?
                .pushViewController(viewController, animated: true)
            return true
        }
        
        JLRoutes.global().addRoute("/digital/cart") { params in
            guard let categoryId = params["category_id"] as? String,
                let operatorId = params["operator_id"] as? String,
                let productId = params["product_id"] as? String,
                let clientNumber = params["client_number"] as? String,
                let instantCheckout = Bool(params["instant_checkout"] as! String)
                else { return false }
            var textInputs = [String:String]()
            if !clientNumber.isEmpty {
                textInputs = ["client_number": clientNumber]
            }
            let cart = DigitalService().purchase(categoryId: categoryId, operatorId:operatorId, productId: productId, textInputs: textInputs, instantCheckout: instantCheckout)
            
            let vc = DigitalCartViewController(cart:cart)
            vc.hidesBottomBarWhenPushed = true
            
            let payment = vc.cartPayment.flatMap { cartPayment -> Observable<Void> in
                let webView = WebViewController()
                webView.hidesBottomBarWhenPushed = true
                webView.strURL = cartPayment.redirectUrl
                webView.strQuery = cartPayment.queryString
                webView.shouldAuthorizeRequest = false
                webView.strTitle = "Pembayaran"
                
                guard let navigationController = UIApplication.topViewController()?.navigationController
                    , let viewController = UIApplication.topViewController() else {
                    return Observable.empty()
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
                    
                    if url?.absoluteString == cartPayment.callbackUrlSuccess {
                        viewController.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
                navigationController.setViewControllers(viewControllers, animated: true)
                return Observable.empty()
            }.subscribe(onError: { (error) in
                print(error)
            }).disposed(by: vc.rx_disposeBag)
            
            UIApplication.topViewController()?
                .navigationController?
                .pushViewController(vc, animated: true)
            
            return true
        }
        
        JLRoutes.global().addRoute("/activation/:activationCode") { (params: [String: Any]!) -> Bool in
            let activationCode = params["activationCode"] as! String
            let attempt = params["a"] as! String
            
            let userManager = UserAuthentificationManager()
            
            if !userManager.isLogin {
                let authenticationService = AuthenticationService()
                
                authenticationService.login(withActivationCode: activationCode,
                                            attempt: attempt,
                                            onSuccess: { login in
                                                onLoginSuccess(login: login!)
                                            },
                                            onFailure: { _ in
                                                
                })
            }
            
            return true
        }
        
        // create shop
        JLRoutes.global().addRoute("/buka-toko-online-gratis") { (_: [String: Any]!) -> Bool in
            let userManager = UserAuthentificationManager()
            if userManager.isLogin && userManager.getShopId() == "0" {
                let controller = OpenShopViewController(nibName: "OpenShopViewController", bundle: nil)
                UIApplication.topViewController()?.navigationController!.pushViewController(controller, animated: true)
            }
            
            return true
        }
        
        // contact us
        JLRoutes.global().addRoute("/contact-us.pl") { (_: [String: Any]!) -> Bool in
            redirectContactUs()
            
            return true
        }
        
        JLRoutes.global().addRoute("/contact-us") { (_: [String: Any]!) -> Bool in
            redirectContactUs()
            
            return true
        }
        
        // webview
        JLRoutes.global().addRoute("/webview") { (params: [String: Any]!) -> Bool in
            let encodedURL = params["url"] as! String
            let decodedURL = encodedURL.removingPercentEncoding!
            let utmString = getUTMString(params)
            let url = decodedURL + utmString
            openWebView(URL(string: url)!)
            
            return true
        }
        
        // promo
        JLRoutes.global().addRoute("/promo") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://www.tokopedia.com/promo" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        JLRoutes.global().addRoute("/promoNative") { (_: [String: Any]!) -> Bool in
            NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 3])
            
            return true
        }
        
        // gold merchant
        JLRoutes.global().addRoute("/gold") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://gold.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        // events
        JLRoutes.global().addRoute("/events") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://events.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //laman kota
        JLRoutes.global().addRoute("/kota") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://kota.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        JLRoutes.global().addRoute("/kota/:cityName") { (params: [String : Any]!) -> Bool in
            let cityName = params["cityName"] as! String
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://kota.tokopedia.com/" + cityName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //tech
        JLRoutes.global().addRoute("/tech") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "http://tech.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        // seller
        JLRoutes.global().addRoute("/seller-center") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://seller.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        // promo category
        JLRoutes.global().addRoute("/promo/category/:categoryName") { (params: [String: Any]!) -> Bool in
            let categoryName = params["categoryName"] as! String
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://www.tokopedia.com/promo/category/" + categoryName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //promo name
        JLRoutes.global().addRoute("/promo/:promoName") { (params: [String : Any]!) -> Bool in
            navigator.navigateToPromoDetail(from: UIApplication.topViewController(), withName: params?["promoName"] as! String)
            return true
        }
        
        //toppicks
        JLRoutes.global().addRoute("/toppicks") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://www.tokopedia.com/toppicks" + utmString
            
            let urlWithAddedFlagApp = addFlagApp(urlString: urlString)
            guard let toppicksUrl = urlWithAddedFlagApp else { return false }
            openWebView(toppicksUrl)
            
            return true
        }
        
        //toppicks name
        JLRoutes.global().addRoute("/toppicks/:toppicksName") { (params: [String: Any]!) -> Bool in
            let topPicksName = params["toppicksName"] as! String
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://www.tokopedia.com/toppicks/" + topPicksName + utmString
            
            let urlWithAddedFlagApp = addFlagApp(urlString: urlString)
            guard let toppicksUrl = urlWithAddedFlagApp else { return false }
            openWebView(toppicksUrl)

            return true
        }
        
        // official store mobile
        JLRoutes.global().addRoute("/official-store/mobile") { (params: [String: Any]!) -> Bool in
            navigator.navigateToOfficialBrands(from: UIApplication.topViewController())
            
            return true
        }
        
        // hotlist
        JLRoutes.global().addRoute("/hot") { (_: [String: Any]!) -> Bool in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "redirectToHotlist"), object: nil)
            return true
        }
        
        // blog marketplace
        JLRoutes.global().addRoute("/blog") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://blog.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        // blog marketplace category
        JLRoutes.global().addRoute("/blog/category/:categoryName") { (params: [String: Any]!) -> Bool in
            let categoryName = params["categoryName"] as! String
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://blog.tokopedia.com/category/" + categoryName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // blog marketplace article
        JLRoutes.global().addRoute("/blog/:year/:month/:title") { (params: [String: Any]!) -> Bool in
            let year = params["year"] as! String
            let month = params["month"] as! String
            let title = params["title"] as! String
            let utmString = getUTMString(params as [String: AnyObject])
            let urlString = "https://blog.tokopedia.com/" + year + "/" + month + "/" + title + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // bantuan
        JLRoutes.global().addRoute("/bantuan/*") { (params: [String: Any]!) -> Bool in
            if let url = params[kJLRouteURLKey] as? NSURL {
                openWebView(url as URL)
                return true
            } else {
                return false
            }
        }
        
        // Tokopedia Tiket
        JLRoutes.global().add(["/kereta-api", "/tiket/kereta-api"]) { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://tiket.tokopedia.com/kereta-api" + utmString
            let title = params["title"] != nil ? params["title"] as! String : ""
            openWebView(NSURL(string: urlString)! as URL, title: title)
            
            return true
        }
        
        // Tokopedia
        JLRoutes.global().addRoute("/tiket/travel") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://tiket.tokopedia.com/travel" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //tiket KAI - blog article
        JLRoutes.global().addRoute("/tiket/travel/:articleName") { (params: [String: Any]!) -> Bool in
            let articleName = params["articleName"] as! String
            let utmString = getUTMString(params)
            let urlString = "https://tiket.tokopedia.com/travel/" + articleName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // pulsa
        JLRoutes.global().addRoute("/pulsa") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // pulsa blog
        JLRoutes.global().addRoute("/pulsa/blog") { (params: [String: Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com/blog" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // pulsa blog article
        JLRoutes.global().addRoute("/pulsa/blog/:articleName") { (params: [String: Any]!) -> Bool in
            let articleName = params["articleName"] as! String
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com/blog/" + articleName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // pulsa to specific page
        JLRoutes.global().addRoute("/pulsa/:pulsaProduct") { (params: [String: Any]!) -> Bool in
            let pulsaProduct = params["pulsaProduct"] as! String
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com/" + pulsaProduct + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        // hot page
        JLRoutes.global().addRoute("/hot/:hotName") { (params: [String: Any]!) -> Bool in
            navigator.navigateToHotlistResult(from: UIApplication.topViewController(), withData: ["key": params["hotName"] as! String])
            return true
        }
        
        // directory
        JLRoutes.global().addRoute("/p/*") { (params: [String: Any]) -> Bool in
            let pathComponent = params[kJLRouteWildcardComponentsKey] as! [String]
            if pathComponent.count > 0 {
                let categoryDataForCategoryResultVC = CategoryDataForCategoryResultVC(pathComponent: pathComponent)
                
                navigator.navigateToIntermediaryCategory(from: UIApplication.topViewController(), withData: categoryDataForCategoryResultVC)
            }
            
            return true
        }
        
        JLRoutes.global().addRoute("/category/:categoryId") { (params: [String: Any]) -> Bool in
            
            var categoryName: String = (params["categoryName"] as? String) ?? ""
            categoryName =  categoryName.replacingOccurrences(of: "+", with: " ")
            
            navigator.navigateToIntermediaryCategory(from: UIApplication.topViewController(), withCategoryId: params["categoryId"] as! String, categoryName: categoryName, isIntermediary: true)
            
            return true
        }
        
        // search
        JLRoutes.global().addRoute("/search/*") { (params: [String: Any]!) -> Bool in
            navigator.navigateToSearch(from: UIApplication.topViewController(), with: (params[kJLRouteURLKey] as! NSURL) as URL!)
            return true
        }
        
        // catalog detail
        JLRoutes.global().addRoute("/catalog/:catalogId/:catalogKey") { (params: [String: Any]!) -> Bool in
            navigator.navigateToCatalog(from: UIApplication.topViewController(), withCatalogID: params["catalogId"] as! String, andCatalogKey: params["catalogKey"] as! String)
            return true
        }
        
        // add product
        JLRoutes.global().addRoute("/add-product/:formId") { (params: [String: Any]!) -> Bool in
            
            if let formId = params["formId"] as? String {
                TPRoutes.retryRequestForFormId(formId)
            }
            
            return true
        }
        
        // home page
        JLRoutes.global().addRoute("home") { (_: [String: Any]!) -> Bool in
            if let viewController = UIApplication.topViewController() {
                viewController.tabBarController?.selectedIndex = 0
                viewController.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page":1])
            }
            return true
        }
        
        //home page
        JLRoutes.global().addRoute("feed") { (params: [String: Any]!) -> Bool in
            if let viewController = UIApplication.topViewController() {
                viewController.tabBarController?.selectedIndex = 0
                viewController.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page":2])
            }
            return true
        }
        
        //shop page
        JLRoutes.global().addRoute("/:shopName") { (params: [String : Any]!) -> Bool in
            let url = params[kJLRouteURLKey] as! URL
            let shopName = params["shopName"] as! String
            isShopExists(shopName, shopExists: { isExists in
                if isExists {
                    navigator.navigateToShop(from: UIApplication.topViewController(), withShopName: shopName)
                } else {
                    let title = params["title"] != nil ? params["title"] as! String : ""
                    openWebView(url, title: title)
                }
            })
            
            return true
        }
        
        // product detail page
        JLRoutes.global().addRoute("/product/:productId") { (params: [String: Any]!) -> Bool in
            let productId = params["productId"] as! String
            NavigateViewController.navigateToProduct(from: UIApplication.topViewController(), withProductID: productId, andName: "", andPrice: "", andImageURL: "", andShopName: "")
            return true
        }
        
        JLRoutes.global().addRoute("/:shopName/:productName") { (params: [String: Any]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            let productName = params["productName"] as! String
            let shopName = params["shopName"] as! String
            
            isShopExists(shopName, shopExists: { isExists in
                if isExists {
                    NavigateViewController.navigateToProduct(from: UIApplication.topViewController(), withProductID: "", andName: productName, andPrice: "", andImageURL: "", andShopName: shopName)
                } else {
                    openWebView(url as URL)
                }
            })
            
            return true
        }
    }
    
    static func onLoginSuccess(login: Login) {
        AnalyticsManager.trackEventName("loginSuccess",
                                        category: GA_EVENT_CATEGORY_LOGIN,
                                        action: GA_EVENT_ACTION_LOGIN_SUCCESS,
                                        label: "Activation Code")
        AnalyticsManager.trackLogin(login)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_TABBAR), object: nil)
        
        triggerPhoneVerification()
    }
    
    static func triggerPhoneVerification() {
        let controller = PhoneVerificationViewController(phoneNumber: "", isFirstTimeVisit: true, didVerifiedPhoneNumber: nil)
        let navigationController = UINavigationController(rootViewController: controller)
        UIApplication.topViewController()?.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    static func retryRequestForFormId(_ formId: String) {
        ProcessingAddProducts.sharedInstance().products.bk_each { form in
            let productForm = form as! ProductEditResult
            if productForm.formId == formId {
                RequestAddEditProduct.fetchAddProduct(productForm, isDuplicate: productForm.duplicate, onSuccess: {
                    ProcessingAddProducts.sharedInstance().products.remove(productForm)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshOnProcessAddProduct"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tokopedia.ADDPRODUCTPOSTNOTIFICATIONNAME"), object: nil)
                    
                }, onFailure: {
                    productForm.isUploadFailed = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshOnProcessAddProduct"), object: nil)
                    var message = "Gagal Tambah Produk"
                    if productForm.duplicate == "1" {
                        message = "Gagal Salin Produk"
                    }
                    TPNotification.showNotification(text: "\(message) \(productForm.product.product_name)",
                                                    buttonTitle: "Coba Kembali",
                                                    userInfo: ["url_deeplink": "tokopedia://add-product/\(productForm.formId)",
                                                               "button_title": "Coba Kembali"],
                                                    categoryIdentifier: "PRODUCT_CATEGORY",
                                                    requestIdentifier: "RETRY_ADD_PRODUCT")
                })
                productForm.isUploadFailed = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshOnProcessAddProduct"), object: nil)
                
            }
        }
    }
    
    static func getUTMString(_ params: [String: Any]) -> String {
        if params["utm_source"] != nil && params["utm_medium"] != nil && params["utm_campaign"] != nil {
            let utmSource = params["utm_source"] as! String
            let utmMedium = params["utm_medium"] as! String
            let utmCampaign = params["utm_campaign"] as! String
            let utmContent = params["utm_content"] as? String ?? ""
            let utmTerm = params["utm_term"] as? String ?? ""
            
            let utmString = "/?utm_source=" + utmSource + "&utm_medium=" + utmMedium + "&utm_campaign=" + utmCampaign
            
            return utmString + "&utm_content=" + utmContent + "&utm_term=" + utmTerm
        } else {
            return ""
        }
    }
    
    static func openWebView(_ url: URL, title: String = "") {
        let controller = WebViewController()
        let userManager = UserAuthentificationManager()
        
        let urlString = url.absoluteString
        
        controller.strURL = userManager.webViewUrl(fromUrl: urlString)
        controller.strTitle = title
        controller.shouldAuthorizeRequest = true
        controller.hidesBottomBarWhenPushed = true
        
        let visibleController = UIApplication.topViewController()
        visibleController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    static func redirectContactUs() {
        let userManager = UserAuthentificationManager()
        if userManager.isLogin {
            NavigateViewController.navigateToContactUs(from: UIApplication.topViewController())
        }
    }
    
    static func isContainPerlPostFix(_ urlPath: String) -> Bool {
        return (urlPath.range(of: ".pl") != nil)
    }
    
    @discardableResult
    static func routeURL(_ url: URL) -> Bool {
        AnalyticsManager.trackCampaign(url)
        return JLRoutes.routeURL(url)
    }
    
    static func isShopExists(_ domain: String, shopExists: @escaping ((Bool) -> Void)) {
        UIApplication.topViewController()?.showWaitOverlay()
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(withBaseUrl: NSString.v4Url(),
                               path: "/v4/shop/get_shop_info.pl",
                               method: .GET,
                               parameter: ["shop_domain": domain],
                               mapping: Shop.mapping(),
                               onSuccess: { mappingResult, _ in
                                   UIApplication.topViewController()?.removeAllOverlays()
                                   guard mappingResult.dictionary() != nil else { return shopExists(false) }
                                   let result: Dictionary = mappingResult.dictionary() as Dictionary
                                   let response = result[""] as! Shop
                                   
                                   if response.result.info == nil {
                                       shopExists(false)
                                   } else {
                                       shopExists(true)
                                   }
        }) { _ in
            shopExists(false)
        }
    }
    
    static func addFlagApp(urlString: String) -> URL? {
        let queryItem = URLQueryItem(name: "flag_app", value: "1")
        var urlComponents = URLComponents(string: urlString)
        guard (urlComponents?.queryItems) != nil else {
            urlComponents?.queryItems = [queryItem]
            return urlComponents?.url
        }
        
        urlComponents?.queryItems?.append(queryItem)
        
        return urlComponents?.url
    }
}
