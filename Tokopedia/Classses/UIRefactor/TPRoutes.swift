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
        
        //create shop
        JLRoutes.globalRoutes().addRoute("/buka-toko-online-gratis") { (params: [String : AnyObject]!) -> Bool in
            let userManager = UserAuthentificationManager()
            if(userManager.isLogin && userManager.getShopId() == "0") {
                let controller = OpenShopViewController(nibName: "OpenShopViewController", bundle: nil)
                UIApplication.topViewController()?.navigationController!.pushViewController(controller, animated: true)
            }
            
            return true
        }
        
        //contact us
        JLRoutes.globalRoutes().addRoute("/contact-us.pl") { (params: [String : AnyObject]!) -> Bool in
            redirectContactUs()

            return true
        }
        
        JLRoutes.globalRoutes().addRoute("/contact-us") { (params: [String : AnyObject]!) -> Bool in
            redirectContactUs()
            
            return true
        }
        
        //hotlist
        JLRoutes.globalRoutes().addRoute("/hot") { (params: [String : AnyObject]!) -> Bool in
            NSNotificationCenter.defaultCenter().postNotificationName("redirectToHotlist", object: nil, userInfo: nil)
            
            return true
        }
        
        //blog marketplace
        JLRoutes.globalRoutes().addRoute("/blog") { (params: [String : AnyObject]!) -> Bool in
            openWebView(NSURL(string: "https://blog.tokopedia.com/")!)
            
            return true
        }
        
        //blog marketplace category
        JLRoutes.globalRoutes().addRoute("/blog/category/:categoryName") { (params: [String : AnyObject]!) -> Bool in
            let categoryName = params["categoryName"] as! String
            let urlString = "https://blog.tokopedia.com/category/" + categoryName + "?utm_source=ios"
            openWebView(NSURL(string: urlString)!)
            
            return true
        }
        
        //blog marketplace article
        JLRoutes.globalRoutes().addRoute("/blog/:year/:month/:title") { (params: [String : AnyObject]!) -> Bool in
            let year = params["year"] as! String
            let month = params["month"] as! String
            let title = params["title"] as! String
            let urlString = "https://blog.tokopedia.com/" + year + "/" + month + "/" + title + "?utm_source=ios"
            openWebView(NSURL(string: urlString)!)
            
            return true
        }
        
        //bantuan
        JLRoutes.globalRoutes().addRoute("/bantuan/*") { (params: [String : AnyObject]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            openWebView(url)
            
            return true
        }
        
        //kereta
        JLRoutes.globalRoutes().addRoute("/kereta-api") { (params: [String : AnyObject]!) -> Bool in
            openWebView(NSURL(string: "https://tiket.tokopedia.com/kereta-api?utm_source=ios")!)
            
            return true
        }
        
        //tiket KAI - blog
        JLRoutes.globalRoutes().addRoute("/tiket/travel") { (params: [String : AnyObject]!) -> Bool in
            openWebView(NSURL(string: "https://tiket.tokopedia.com/travel?utm_source=ios")!)
            
            return true
        }
        
        //tiket KAI - blog article
        JLRoutes.globalRoutes().addRoute("/tiket/travel/:articleName") { (params: [String : AnyObject]!) -> Bool in
            let articleName = params["articleName"] as! String
            let urlString = "https://tiket.tokopedia.com/travel/" + articleName + "?utm_source=ios"
            openWebView(NSURL(string: urlString)!)
            
            return true
        }
        
        //pulsa
        JLRoutes.globalRoutes().addRoute("/pulsa") { (params: [String : AnyObject]!) -> Bool in
            openWebView(NSURL(string: "https://pulsa.tokopedia.com?utm_source=ios")!)
            
            return true
        }
        
        //pulsa blog
        JLRoutes.globalRoutes().addRoute("/pulsa/blog") { (params: [String : AnyObject]!) -> Bool in
            openWebView(NSURL(string: "https://pulsa.tokopedia.com/blog?utm_source=ios")!)
            
            return true
        }
        
        //pulsa blog article
        JLRoutes.globalRoutes().addRoute("/pulsa/blog/:articleName") { (params: [String : AnyObject]!) -> Bool in
            let articleName = params["articleName"] as! String
            let urlString = "https://pulsa.tokopedia.com/blog/" + articleName + "?utm_source=ios"
            openWebView(NSURL(string: urlString)!)
            
            return true
        }
        
        //pulsa to specific page
        JLRoutes.globalRoutes().addRoute("/pulsa/:pulsaProduct") { (params: [String : AnyObject]!) -> Bool in
            let pulsaProduct = params["pulsaProduct"] as! String
            let urlString = "https://pulsa.tokopedia.com/" + pulsaProduct  + "?utm_source=ios"
            openWebView(NSURL(string: urlString)!)
            
            return true
        }
        
        //hot page
        JLRoutes.globalRoutes().addRoute("/hot/:hotName") { (params: [String : AnyObject]!) -> Bool in
            navigator.navigateToHotlistResultFromViewController(UIApplication.topViewController(), withData: ["key" : params["hotName"] as! String])
            return true
        }
        
        //directory
        JLRoutes.globalRoutes().addRoute("/p/*") { (params: [String : AnyObject]) -> Bool in
            let pathComponent = params[kJLRouteWildcardComponentsKey] as! [String]
            if(pathComponent.count > 0) {
                let departments = [
                    "department_1" : pathComponent[0],
                    "department_2" : pathComponent.count > 1 ? pathComponent[1] : "",
                    "department_3" : pathComponent.count > 2 ? pathComponent[2] : "",
                    "st" : "product",
                    "sc_identifier" : pathComponent.joinWithSeparator("_")
                ]
                
                navigator.navigateToSearchFromViewController(UIApplication.topViewController(), withData: departments)
            }
 
            return true
        }
        
        //search
        JLRoutes.globalRoutes().addRoute("/search/*") { (params: [String : AnyObject]!) -> Bool in
            navigator.navigateToSearchFromViewController(UIApplication.topViewController(), withURL: params[kJLRouteURLKey] as! NSURL)
            return true
        }
        
        //catalog detail
        JLRoutes.globalRoutes().addRoute("/catalog/:catalogId/:catalogKey") { (params: [String : AnyObject]!) -> Bool in
            navigator.navigateToCatalogFromViewController(UIApplication.topViewController(), withCatalogID: params["catalogId"] as! String, andCatalogKey: params["catalogKey"] as! String)
            return true
        }
        
        //shop page
        JLRoutes.globalRoutes().addRoute("/:shopName") { (params: [String : AnyObject]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            let shopName = params["shopName"] as! String
            if(DeeplinkController.shouldOpenWebViewURL(url) || isContainPerlPostFix(shopName)) {
                openWebView(url)
            } else {
                navigator.navigateToShopFromViewController(UIApplication.topViewController(), withShopName: shopName)
            }
            
            return true
        }
        
        //product detail page
        JLRoutes.globalRoutes().addRoute("/:shopName/:productName") { (params: [String : AnyObject]!) -> Bool in
            let url = params[kJLRouteURLKey] as! NSURL
            let productName = params["productName"] as! String
            let shopName = params["shopName"] as! String
            
            if(DeeplinkController.shouldOpenWebViewURL(url) || isContainPerlPostFix(productName)) {
                openWebView(url)
            } else {
                let data = [
                    "product_key" : productName,
                    "shop_domain" : shopName
                ]
                navigator.navigateToProductFromViewController(UIApplication.topViewController(), withData: data)
            }
            
            return true
        }
        
    }
    
    
    
    static func openWebView(url: NSURL) {
        let controller = WebViewController()
        let userManager = UserAuthentificationManager()
        
        var urlString = url.absoluteString
        let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}&").invertedSet
        urlString = "https://js.tokopedia.com/wvlogin?uid=\(userManager.getUserId())&token=\(userManager.getMyDeviceToken())&url=\(urlString!.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!)"
        
        controller.strURL = urlString
        
        let visibleController = UIApplication.topViewController()
        visibleController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    static func redirectContactUs() {
        let userManager = UserAuthentificationManager()
        if(userManager.isLogin) {
            let dependencies = TPContactUsDependencies()
            dependencies.pushContactUsViewControllerFromNavigation(UIApplication.topViewController()?.navigationController!)
        }
    }
    
    static func isContainPerlPostFix(urlPath: String) -> Bool {
        return (urlPath.rangeOfString(".pl") != nil)
    }
    
    static func routeURL(url: NSURL) -> Bool {
        AnalyticsManager.trackCampaign(url)
        return JLRoutes.routeURL(url)
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
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
