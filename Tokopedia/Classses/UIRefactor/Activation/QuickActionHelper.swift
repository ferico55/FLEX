//
//  QuickActionHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 2/22/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

enum ShortcutItemType: String {
    case addProduct = "add"
    case searchProduct = "search"
    case readInbox = "message"
}


@objc (QuickActionHelper)
class QuickActionHelper: NSObject {

    static let sharedInstance = QuickActionHelper()
    
    func registerShortcutItems() {
        guard #available(iOS 9.1, *),
        let bundleID = Bundle.main.bundleIdentifier else {
            return
        }
        
        let userAuthenticationManager = UserAuthentificationManager()
        guard userAuthenticationManager.isLogin else {
            let searchProductItem = UIApplicationShortcutItem(type: bundleID + "." + ShortcutItemType.searchProduct.rawValue, localizedTitle: "Cari Produk", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .search), userInfo: nil)
            UIApplication.shared.shortcutItems = [searchProductItem]
            return
        }
        
        let shopId = userAuthenticationManager.getShopId()
        guard shopId != "0" else {
            let searchProductItem = UIApplicationShortcutItem(type: bundleID + "." + ShortcutItemType.searchProduct.rawValue, localizedTitle: "Cari Produk", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .search), userInfo: nil)
            let readInboxItem = UIApplicationShortcutItem(type: bundleID + "." + ShortcutItemType.readInbox.rawValue, localizedTitle: "Baca Inbox", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .message), userInfo: nil)
            UIApplication.shared.shortcutItems = [searchProductItem, readInboxItem]
            
            return
        }
       
        let searchProductItem = UIApplicationShortcutItem(type: bundleID + "." + ShortcutItemType.searchProduct.rawValue, localizedTitle: "Cari Produk", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .search), userInfo: nil)
        let readInboxItem = UIApplicationShortcutItem(type: bundleID + "." + ShortcutItemType.readInbox.rawValue, localizedTitle: "Baca Inbox", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .message), userInfo: nil)
        let addProductItem = UIApplicationShortcutItem(type: bundleID + "." + ShortcutItemType.addProduct.rawValue, localizedTitle: "Tambahkan Produk", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
        UIApplication.shared.shortcutItems = [searchProductItem, readInboxItem, addProductItem]
    }
    
    @available(iOS 9.1, *)
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) {
        let type = shortcutItem.type.components(separatedBy: ".").last!
        
        if let shortcutItemType = ShortcutItemType.init(rawValue: type) {
            switch shortcutItemType {
            case .addProduct:
                let navigator = NavigateViewController()
                navigator.navigateToAddProduct(from: UIApplication.topViewController())
            case .searchProduct:
                NotificationCenter.default.post(name: Notification.Name(rawValue: "tokopedia.kTKPD_REDIRECT_TO_HOME"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "activateSearch"), object: nil, userInfo: nil)
            case .readInbox:
                let navigator = NavigateViewController()
                navigator.navigateToInboxMessage(from: UIApplication.topViewController())
            }
            
            // send analytics
            self.sendAnalytics(shortcutItemType)
        }
    }
    
    func sendAnalytics(_ shortcutItemType: ShortcutItemType) {
        switch shortcutItemType {
        case .addProduct:
            AnalyticsManager.trackEventName("clickQuickAction", category: GA_EVENT_CATEGORY_QUICK_ACTION, action: GA_EVENT_ACTION_CLICK, label: "Add Product - Login with Shop")
        case .searchProduct:
            let userAuthenticationManager = UserAuthentificationManager()
            if userAuthenticationManager.isLogin {
                let shopId = userAuthenticationManager.getShopId()
                if shopId != "0" {
                    AnalyticsManager.trackEventName("clickQuickAction", category: GA_EVENT_CATEGORY_QUICK_ACTION, action: GA_EVENT_ACTION_CLICK, label: "Search Product - Login with Shop")
                } else {
                    AnalyticsManager.trackEventName("clickQuickAction", category: GA_EVENT_CATEGORY_QUICK_ACTION, action: GA_EVENT_ACTION_CLICK, label: "Search Product - Login with No Shop")
                }
            } else {
                AnalyticsManager.trackEventName("clickQuickAction", category: GA_EVENT_CATEGORY_QUICK_ACTION, action: GA_EVENT_ACTION_CLICK, label: "Search Product - Non Login")
            }
        case .readInbox:
            let userAuthenticationManager = UserAuthentificationManager()
            let shopId = userAuthenticationManager.getShopId()
            if shopId != "0" {
                AnalyticsManager.trackEventName("clickQuickAction", category: GA_EVENT_CATEGORY_QUICK_ACTION, action: GA_EVENT_ACTION_CLICK, label: "Read Message - Login with Shop")
            } else {
                AnalyticsManager.trackEventName("clickQuickAction", category: GA_EVENT_CATEGORY_QUICK_ACTION, action: GA_EVENT_ACTION_CLICK, label: "Read Message - Login with No Shop")
            }
        }
    }
}
