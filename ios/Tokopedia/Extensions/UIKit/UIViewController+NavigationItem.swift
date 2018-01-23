//
//  UIViewController+NavigationItem.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
extension UIViewController {
    
    enum BarButtonSide {
        case left
        case right
    }
    
    func setBarButton(withTitle title: String, side: BarButtonSide, font: UIFont?, textColor: UIColor?, action: Selector?) {
        let barButton = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        if let font = font {
            barButton.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        }
        if let color = textColor {
            barButton.setTitleTextAttributes([NSForegroundColorAttributeName: color], for: .normal)
        }
        
        if side == .right {
            self.navigationItem.rightBarButtonItem = barButton
        } else {
            self.navigationItem.leftBarButtonItem = barButton
        }
    }
    
    func setBarButton(withImage image: UIImage, side: BarButtonSide, action: Selector?) {
        let barButton = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        if side == .right {
            self.navigationItem.rightBarButtonItem = barButton
        } else {
            self.navigationItem.leftBarButtonItem = barButton
        }
    }
}
