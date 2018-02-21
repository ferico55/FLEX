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
        let currency = (params["currency"] as? String) ?? ""
        var metadata: [String: Any] = [:]
        var products: [BNCProduct] = []
        if let itemName = params["items[name]"] as? String {
            let product = BNCProduct()
            product.name = itemName
            product.sku = (params["items[id]"] as? String) ?? "PULSA"
            let price = (params["items[price]"] as? String) ?? ""
            product.price = NSDecimalNumber(string: price)
            product.quantity = (params["items[quantity]"] as? NSNumber) ?? 0.0
            products.append(product)
            metadata["productType"] = "digital"
        } else {
            metadata["productType"] = "marketplace"
        }
        let productItems: [[String:Any]] = (params["items"] as? [[String : Any]]) ?? []
        for pItem in productItems {
            let product = BNCProduct()
            product.sku = (pItem["id"] as? String) ?? ""
            product.name = (pItem["name"] as? String) ?? ""
            let price = (pItem["price"] as? NSNumber) ?? 0
            product.price = NSDecimalNumber(decimal: price.decimalValue)
            product.quantity = (pItem["quantity"] as? NSNumber) ?? 0.0
            products.append(product)
        }
        let commerceEvent = BNCCommerceEvent()
        commerceEvent.currency = currency
        if let revenue = params["amount"] as? String {
            commerceEvent.revenue = NSDecimalNumber(string: revenue)
        }
        commerceEvent.products = products
        metadata["userId"] = UserAuthentificationManager().getUserId()
        metadata["paymentId"] = params["transaction_id"]
        Branch.getInstance().send(commerceEvent, metadata: metadata, withCompletion: { (response, error) in
        })
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
