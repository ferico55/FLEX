//
//  BranchAnalytics.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Branch
import Foundation

internal class BranchAnalytics: NSObject {
    internal func sendCommerceEvent(params:[String:Any]) {
        var products = [BranchUniversalObject]()
        if let itemName = params["items[name]"] as? String {
            let buo = BranchUniversalObject()
            buo.title = itemName
            let metadata = BranchContentMetadata()
            metadata.sku = (params["items[id]"] as? String) ?? ""
            metadata.productName = itemName
            let price = (params["items[price]"] as? String) ?? ""
            metadata.price = NSDecimalNumber(string:price)
            metadata.quantity = (params["items[quantity]"] as? NSNumber)?.doubleValue ?? 0.0
            metadata.currency = BNCCurrency.IDR
            buo.contentMetadata = metadata
            products.append(buo)
        }
        let productItems: [[String:Any]] = (params["items"] as? [[String : Any]]) ?? []
        for pItem in productItems {
            let buo = BranchUniversalObject()
            buo.title = (pItem["name"] as? String) ?? ""
            let metadata = BranchContentMetadata()
            metadata.sku = (pItem["id"] as? String) ?? ""
            metadata.productName = (pItem["name"] as? String) ?? ""
            let price = (pItem["price"] as? NSNumber) ?? 0
            metadata.price = NSDecimalNumber(string: price.stringValue)
            metadata.quantity = (pItem["quantity"] as? NSNumber)?.doubleValue ?? 0.0
            metadata.currency = BNCCurrency.IDR
            buo.contentMetadata = metadata
            products.append(buo)
        }
        let event = BranchEvent.standardEvent(.purchase)
        event.contentItems = NSMutableArray(array: products)
        event.currency = .IDR
        if let revenue = params["amount"] as? String {
            event.revenue = NSDecimalNumber(string: revenue)
        }
        event.transactionID = params["transaction_id"] as? String
        event.customData = ["userId":UserAuthentificationManager().getUserId()]
        event.logEvent()
    }
    internal func sendLoginSignupEvent(isLogin:Bool) {
        let name = (isLogin) ? "login" : "sign_up"
        let event = BranchEvent.customEvent(withName: name)
        event.customData["email"] = UserAuthentificationManager().getUserEmail()
        event.customData["phone"] = UserAuthentificationManager().getUserPhoneNumber() ?? ""
        event.logEvent()
    }
    //    MARK: - GA_EVENT_CATEGORY_LOGIN
    internal func trackReferralCodeLabelEvent(action: String) {
        self.trackClickReferralEvent( action: action, label: "code")
    }
    internal func trackClickReferralEvent(action: String, label: String) {
        self.trackReferralEvent(name: "clickReferral",
                                        action: action,
                                        label: label)
    }
    private func trackReferralEvent(name: String, action: String, label: String) {
        AnalyticsManager.trackEventName(name,
                                        category: GA_EVENT_CATEGORY_Referral,
                                        action: action,
                                        label: label)
    }
    //    MARK:- MoEngage events
    internal func moEngageTrackScreenEvent(name:String) {
        AnalyticsManager.moEngageTrackEvent(withName: "Referral_Screen_Launched", attributes: ["screen_name" : name])
    }
    internal func moEngageTrackShareEvent(channel:String) {
        AnalyticsManager.moEngageTrackEvent(withName: "Share_Event", attributes: ["channel" : channel])
    }
}
