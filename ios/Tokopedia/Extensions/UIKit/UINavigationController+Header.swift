//
//  UINavigationController+Header.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 02/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

extension UINavigationController {
    
    open override class func initialize() {
        // make sure this isn't a subclass
        guard self === UINavigationController.self else { return }
        UINavigationController.setDefaultNav()
    }
    
    func setGreen() {
        self.navigationBar.barTintColor = UIColor.tpGreen()
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.shadowOpacity = 0
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage(color: UIColor.tpGreen(), size: CGSize(width: 1, height: 0.3))
        
        let barButtonAttributes = [NSStrokeColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: UIControlState.normal)
        
        if #available(iOS 11.0, *) {
            // this align back button to title view in ios 11
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0.1), for: .default)
        } else {
            // this causes back button to always appears white in ios 11
            UIBarButtonItem.appearance().tintColor = .white
        }
        
        if #available(iOS 9.0, *) {
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(barButtonAttributes, for: .normal)
            UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.white
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setWhite() {
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.tintColor = UIColor.tpPrimaryBlackText()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)]
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.12), size: CGSize(width: 1, height: 0.3))
        
        let barButtonAttributes = [NSStrokeColorAttributeName: UIColor.tpPrimaryBlackText()]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: UIControlState.normal)
    
        if #available(iOS 11.0, *) {
            // this align back button to title view in ios 11
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0.1), for: .default)
        } else {
            // this causes back button to always appears white in ios 11
            UIBarButtonItem.appearance().tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        }
        
        if #available(iOS 9.0, *) {
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(barButtonAttributes, for: .normal)
            UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.tpPrimaryBlackText()
        }
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    class func setDefaultNav() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.12), size: CGSize(width: 1, height: 0.3))
        
        let barButtonAttributes = [NSStrokeColorAttributeName: UIColor.tpPrimaryBlackText()]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: UIControlState.normal)
        
        if #available(iOS 11.0, *) {
            // this align back button to title view in ios 11
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0.1), for: .default)
        } else {
            // this causes back button to always appears white in ios 11
            UIBarButtonItem.appearance().tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        }
        
        if #available(iOS 9.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.tpPrimaryBlackText()
        }
        
        UIApplication.shared.statusBarStyle = .default
    }
    
}
