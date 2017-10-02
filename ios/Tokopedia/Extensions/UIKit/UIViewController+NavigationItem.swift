//
//  UIViewController+NavigationItem.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
extension UIViewController {
    func setLeftBarButton(withTitle title: String, action: Selector) {
        let barButton = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        self.navigationItem.leftBarButtonItem = barButton
    }
}
