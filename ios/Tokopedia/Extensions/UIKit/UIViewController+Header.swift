//
//  UIViewController+Header.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 02/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import CFAlertViewController
import Foundation

extension UIViewController {
    
    open override class func initialize() {
        // make sure this isn't a subclass
        guard self === UIViewController.self else { return }
        
        let originalMethod = class_getInstanceMethod(self, #selector(self.viewWillAppear(_:)))
        let swizzledMethod = class_getInstanceMethod(self, #selector(self.TP_viewWillAppear(animated:)))
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
        let originalPresentMethod = class_getInstanceMethod(self, #selector(self.present(_:animated:completion:)))
        let swizzledPresentMethod = class_getInstanceMethod(self, #selector(self.TP_present(viewControllerToPresent:animated:completion:)))
        method_exchangeImplementations(originalPresentMethod, swizzledPresentMethod)
    }
    
    // MARK: - Method Swizzling
    public func TP_viewWillAppear(animated: Bool) {
        self.TP_viewWillAppear(animated: animated)
        
        let viewControllerName = NSStringFromClass(type(of: self))
        debugPrint("Class Name: \(viewControllerName)")
        
        guard let nav = self.navigationController, let top = nav.topViewController, type(of: self) == type(of: top) else { return }
        if self.isHomePage(top) {
            nav.setGreen()
        } else if type(of: top) != GroupChatDetailViewController.self {
            nav.setWhite()
        }
    }
    
    public func TP_present(viewControllerToPresent: UIViewController,
                           animated: Bool,
                           completion: (() -> Void)? = nil) {
        self.TP_present(viewControllerToPresent: viewControllerToPresent, animated: animated, completion: completion)
        
        guard (type(of: viewControllerToPresent).isSubclass(of: UIViewController.self) &&
            type(of: viewControllerToPresent) != UISearchController.self &&
            type(of: viewControllerToPresent) != UIAlertController.self &&
            type(of: viewControllerToPresent) != CFAlertViewController.self &&
            type(of: viewControllerToPresent) != TopAdsInfoActionSheet.self &&
            type(of: viewControllerToPresent) != GroupChatDetailViewController.self &&
            type(of: viewControllerToPresent) != UIActivityViewController.self) ||
            type(of: viewControllerToPresent).isSubclass(of: UINavigationController.self) else { return }
        
        UINavigationController.setDefaultNav()
    }
    
    public func isHomePage(_ viewController: UIViewController) -> Bool {
        
        let elements = [HomeTabViewController.self, HotlistViewController.self, MyWishlistViewController.self, TransactionCartViewController.self, MoreWrapperViewController.self, LoginViewController.self]
        
        var status = false
        for element in elements {
            if type(of: viewController) == element {
                status = true
            }
        }
        return status
    }
}
