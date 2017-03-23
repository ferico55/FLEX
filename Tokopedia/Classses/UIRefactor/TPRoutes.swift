//
//  TPRoutes.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import JLRoutes

class TPRoutes: NSObject {
    
    static func configureRoutes() {
        let navigator = NavigateViewController()
        
        JLRoutes.global().unmatchedURLHandler = { (route, url, dictionary) in
            self.openWebView(url!)
        }
        
        JLRoutes.global().addRoute("/activation/:activationCode") { (params: [String : Any]!) -> Bool in
            let activationCode = params["activationCode"] as! String
            let attempt = params["a"] as! String
            
            let userManager = UserAuthentificationManager()
            
            if !userManager.isLogin {
                let authenticationService = AuthenticationService()
                
                authenticationService.login(
                    withActivationCode: activationCode,
                    attempt: attempt,
                    onSuccess: { (login) in
                        onLoginSuccess(login: login!)
                },
                    onFailure: { (error) in
                        
                })
            }
            
            return true
        }
        
        //create shop
        JLRoutes.global().addRoute("/buka-toko-online-gratis") { (params: [String : Any]!) -> Bool in
            let userManager = UserAuthentificationManager()
            if(userManager.isLogin && userManager.getShopId() == "0") {
                let controller = OpenShopViewController(nibName: "OpenShopViewController", bundle: nil)
                UIApplication.topViewController()?.navigationController!.pushViewController(controller, animated: true)
            }
            
            return true
        }
        
        //contact us
        JLRoutes.global().addRoute("/contact-us.pl") { (params: [String : Any]!) -> Bool in
            redirectContactUs()

            return true
        }
        
        JLRoutes.global().addRoute("/contact-us") { (params: [String : Any]!) -> Bool in
            redirectContactUs()
            
            return true
        }
        
        //webview
        JLRoutes.global().addRoute("/webview") { (params: [String : Any]!) -> Bool in
            let encodedURL = params["url"] as! String
            let decodedURL = encodedURL.removingPercentEncoding!
            
            openWebView(URL(string: decodedURL)!)
            
            return true
        }
        
        //promo
        JLRoutes.global().addRoute("/promo") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://www.tokopedia.com/promo" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //gold merchant
        JLRoutes.global().addRoute("/gold") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://gold.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //events
        JLRoutes.global().addRoute("/events") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://events.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //halaman kota
        JLRoutes.global().addRoute("/kota") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://kota.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //tech
        JLRoutes.global().addRoute("/tech") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "http://tech.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //seller
        JLRoutes.global().addRoute("/seller-center") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://seller.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //promo category
        JLRoutes.global().addRoute("/promo/category/:categoryName") { (params: [String : Any]!) -> Bool in
            let categoryName = params["categoryName"] as! String
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://www.tokopedia.com/promo/category/" + categoryName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //hotlist
        JLRoutes.global().addRoute("/hot") { (params: [String : Any]!) -> Bool in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "redirectToHotlist"), object: nil)
            return true
        }
        
        //blog marketplace
        JLRoutes.global().addRoute("/blog") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://blog.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            return true
        }
        
        //blog marketplace category
        JLRoutes.global().addRoute("/blog/category/:categoryName") { (params: [String : Any]!) -> Bool in
            let categoryName = params["categoryName"] as! String
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://blog.tokopedia.com/category/" + categoryName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //blog marketplace article
        JLRoutes.global().addRoute("/blog/:year/:month/:title") { (params: [String : Any
            ]!) -> Bool in
            let year = params["year"] as! String
            let month = params["month"] as! String
            let title = params["title"] as! String
            let utmString = getUTMString(params as [String : AnyObject])
            let urlString = "https://blog.tokopedia.com/" + year + "/" + month + "/" + title + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //bantuan
        JLRoutes.global().addRoute("/bantuan/*") { (params: [String : Any]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            openWebView(url as URL)
            
            return true
        }
        
        //Tokopedia Tiket
        JLRoutes.global().add(["/kereta-api", "/tiket/kereta-api"]) { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://tiket.tokopedia.com/kereta-api" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }

        //Tokopedia
        JLRoutes.global().addRoute("/tiket/travel") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://tiket.tokopedia.com/travel" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //tiket KAI - blog article
        JLRoutes.global().addRoute("/tiket/travel/:articleName") { (params: [String : Any]!) -> Bool in
            let articleName = params["articleName"] as! String
            let utmString = getUTMString(params)
            let urlString = "https://tiket.tokopedia.com/travel/" + articleName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //pulsa
        JLRoutes.global().addRoute("/pulsa") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //pulsa blog
        JLRoutes.global().addRoute("/pulsa/blog") { (params: [String : Any]!) -> Bool in
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com/blog" + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //pulsa blog article
        JLRoutes.global().addRoute("/pulsa/blog/:articleName") { (params: [String : Any]!) -> Bool in
            let articleName = params["articleName"] as! String
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com/blog/" + articleName + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //pulsa to specific page
        JLRoutes.global().addRoute("/pulsa/:pulsaProduct") { (params: [String : Any]!) -> Bool in
            let pulsaProduct = params["pulsaProduct"] as! String
            let utmString = getUTMString(params)
            let urlString = "https://pulsa.tokopedia.com/" + pulsaProduct + utmString
            openWebView(NSURL(string: urlString)! as URL)
            
            return true
        }
        
        //hot page
        JLRoutes.global().addRoute("/hot/:hotName") { (params: [String : Any]!) -> Bool in
            navigator.navigateToHotlistResult(from: UIApplication.topViewController(), withData: ["key" : params["hotName"] as! String])
            return true
        }
        
        //directory
        JLRoutes.global().addRoute("/p/*") { (params: [String : Any]) -> Bool in
            let pathComponent = params[kJLRouteWildcardComponentsKey] as! [String]
            if(pathComponent.count > 0) {
                let departments = [
                    "department_1" : pathComponent[0],
                    "department_2" : pathComponent.count > 1 ? pathComponent[1] : "",
                    "department_3" : pathComponent.count > 2 ? pathComponent[2] : "",
                    "st" : "product",
                    "sc_identifier" : pathComponent.joined(separator: "_")
                ]
                
                navigator.navigateToSearch(from: UIApplication.topViewController(), withData: departments)
            }
 
            return true
        }
        
        //search
        JLRoutes.global().addRoute("/search/*") { (params: [String : Any]!) -> Bool in
            navigator.navigateToSearch(from: UIApplication.topViewController(), with: (params[kJLRouteURLKey] as! NSURL) as URL!)
            return true
        }
        
        //catalog detail
        JLRoutes.global().addRoute("/catalog/:catalogId/:catalogKey") { (params: [String : Any]!) -> Bool in
            navigator.navigateToCatalog(from: UIApplication.topViewController(), withCatalogID: params["catalogId"] as! String, andCatalogKey: params["catalogKey"] as! String)
            return true
        }
        
        //shop page
        JLRoutes.global().addRoute("/:shopName") { (params: [String : Any]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            let shopName = params["shopName"] as! String
            isShopExists(shopName, shopExists: { (isExists) in
                if isExists {
                    navigator.navigateToShop(from: UIApplication.topViewController(), withShopName: shopName)
                } else {
                    openWebView(url as URL)
                }
            })
            
            
            return true
        }
        
        //product detail page
        JLRoutes.global().addRoute("/:shopName/:productName") { (params: [String : Any]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            let productName = params["productName"] as! String
            let shopName = params["shopName"] as! String
            
            isShopExists(shopName, shopExists: { (isExists) in
                if isExists {
                    let data = [
                        "product_key" : productName,
                        "shop_domain" : shopName
                    ]
                    navigator.navigateToProduct(from: UIApplication.topViewController(), withData: data)
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
        
        AuthenticationService.shared().storeCredential(toKeychain: login)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_TABBAR), object: nil)
        
        triggerPhoneVerification()
    }
    
    static func triggerPhoneVerification() {
        let controller = PhoneVerificationViewController(phoneNumber: "", isFirstTimeVisit: true)
        let navigationController = UINavigationController(rootViewController: controller)
        UIApplication.topViewController()?.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    static func getUTMString(_ params: [String : Any]) -> String {
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
    
    static func openWebView(_ url: URL) {
        let controller = WebViewController()
        let userManager = UserAuthentificationManager()
        
        let urlString = url.absoluteString
        
        controller.strURL = userManager.webViewUrl(fromUrl: urlString)
        controller.shouldAuthorizeRequest = true
        
        let visibleController = UIApplication.topViewController()
        visibleController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    static func redirectContactUs() {
        let userManager = UserAuthentificationManager()
        if(userManager.isLogin) {
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
                                          parameter: ["shop_domain" : domain],
                                          mapping: Shop.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            UIApplication.topViewController()?.removeAllOverlays()
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! Shop
                                            
                                            if response.result.info == nil {
                                                shopExists(false)
                                            } else {
                                                shopExists(true)
                                            }
            }) { (error) in
                shopExists(false)
        }
    }

    
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let search = base as? UISearchController {
            return search.presentingViewController
        }
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
