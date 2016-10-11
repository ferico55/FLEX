//
//  TPRoutes.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class TPRoutes: NSObject {
    
    override init() {
        super.init()
        
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
        
        //kereta
        JLRoutes.globalRoutes().addRoute("/hot") { (params: [String : AnyObject]!) -> Bool in
            NSNotificationCenter.defaultCenter().postNotificationName("redirectToHotlist", object: nil, userInfo: nil)
            
            return true
        }
        
        //kereta
        JLRoutes.globalRoutes().addRoute("/kereta-api") { (params: [String : AnyObject]!) -> Bool in
            self.openWebView(NSURL(string: "https://tiket.tokopedia.com/kereta-api?utm_source=ios")!)
            
            return true
        }
        
        //pulsa
        JLRoutes.globalRoutes().addRoute("/pulsa") { (params: [String : AnyObject]!) -> Bool in
            self.openWebView(NSURL(string: "https://pulsa.tokopedia.com?utm_source=ios")!)
            
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
            if(DeeplinkController.shouldOpenWebViewURL(url) || self.isContainPerlPostFix(shopName)) {
                self.openWebView(url)
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
            
            if(DeeplinkController.shouldOpenWebViewURL(url) || self.isContainPerlPostFix(productName)) {
                self.openWebView(url)
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
    
    private func openWebView(url: NSURL) {
        let controller = WebViewController()
        let userManager = UserAuthentificationManager()
        
        var urlString = url.absoluteString
        let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}&").invertedSet
        urlString = "https://js.tokopedia.com/wvlogin?uid=\(userManager.getUserId())&token=\(userManager.getMyDeviceToken())&url=\(urlString!.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!)"
        
        controller.strURL = urlString
        
        let visibleController = UIApplication.topViewController()
        visibleController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func isContainPerlPostFix(urlPath: String) -> Bool {
        return (urlPath.rangeOfString(".pl") != nil)
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
