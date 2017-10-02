//
//  UIViewController+Presentation.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 04/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
extension UIViewController {
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
}
