//
//  UISplitViewControllerCategory.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

extension UISplitViewController {
    func replaceDetailViewController(viewController: UIViewController) {
        let masterViewController = viewControllers.first!
        viewControllers = [masterViewController, viewController]
    }
}