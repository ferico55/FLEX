//
//  TPRoutes.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class TPRoutes: NSObject {
    
    var activeController: UIViewController!
    
    init(viewController: UIViewController) {
        super.init()
        
        
        //shop page
        JLRoutes.globalRoutes().addRoute("/:shopName/:productName") { (params: [String : AnyObject]!) -> Bool in
            let navigator = NavigateViewController()
            navigator.navigateToShopFromViewController(UIApplication.topViewController(), withShopName: params["shopName"] as! String)
            
            return true
        }

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
