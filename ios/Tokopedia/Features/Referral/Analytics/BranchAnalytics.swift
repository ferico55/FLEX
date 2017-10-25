//
//  BranchAnalytics.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Branch

class BranchAnalytics: NSObject {
    func sendCommerceEvent(params:[String:Any], revenue: NSNumber) {
        let productItems: [[String:Any]] = (params["items"] as? [[String : Any]]) ?? []
        let currency = (params["currency"] as? String) ?? ""
        var products: [BNCProduct] = []
        for pItem in productItems {
            let product = BNCProduct()
            product.sku = (pItem["id"] as? String) ?? ""
            product.name = (pItem["name"] as? String) ?? ""
            product.price = (pItem["price"] as? NSDecimalNumber) ?? 0.0
            product.quantity = (pItem["quantity"] as? NSNumber) ?? 0.0
            products.append(product)
        }
        let commerceEvent = BNCCommerceEvent.init()
        commerceEvent.currency = currency
        commerceEvent.shipping = 11.22
        commerceEvent.revenue = (revenue as? NSDecimalNumber) ?? 0.0
        commerceEvent.products = products
        let metadata: [String: Any] = [:]
        Branch.getInstance().send(commerceEvent, metadata: metadata, withCompletion: { (response, error) in
        })
    }
}
