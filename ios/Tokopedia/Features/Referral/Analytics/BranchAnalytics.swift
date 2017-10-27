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
    func sendCommerceEvent(params:[String:Any]) {
        let revenue: NSNumber = (params["amount"] as? NSNumber) ?? 0
        let productItems: [[String:Any]] = (params["items"] as? [[String : Any]]) ?? []
        let currency = (params["currency"] as? String) ?? ""
        var products: [BNCProduct] = []
        for pItem in productItems {
            let product = BNCProduct()
            product.sku = (pItem["id"] as? String) ?? ""
            product.name = (pItem["name"] as? String) ?? ""
            let price = (pItem["price"] as? NSNumber) ?? 0
            product.price = NSDecimalNumber(decimal: price.decimalValue)
            product.quantity = (pItem["quantity"] as? NSNumber) ?? 0.0
            products.append(product)
        }
        let commerceEvent = BNCCommerceEvent.init()
        commerceEvent.currency = currency
        commerceEvent.revenue = NSDecimalNumber(decimal: revenue.decimalValue)
        commerceEvent.products = products
        let metadata: [String: Any] = [:]
        Branch.getInstance().send(commerceEvent, metadata: metadata, withCompletion: { (response, error) in
        })
    }
}
