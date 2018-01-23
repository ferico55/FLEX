//
//  DigitalAnalyticsManager.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    enum DigitalEventName: String {
        case homepage = "userInteractionHomePage"
        case tracking = "rechargeTracking"
    }
    
    static func trackRechargeEvent(event: DigitalEventName, category: DigitalForm?, operators: DigitalOperator?, product: DigitalProduct?, action: String) {
        var categoryName = ""
        var operatorName = ""
        var productName = ""
        var labelName = ""
        
        if let cat = category {
            categoryName = "\(GA_EVENT_CATEGORY_RECHARGE) - \(cat.name)"
            labelName = "\(cat.name)"
        }
        if let oper = operators {
            operatorName = oper.name
            labelName = "\(operatorName)"
        }
        
        if let prod = product {
            productName = prod.priceText
            labelName = "\(operatorName) - \(productName)"
        }
        
        AnalyticsManager.trackEventName(event.rawValue, category: categoryName, action: action, label: labelName)
    }
    
    static func trackRechargeEvent(event: DigitalEventName, cart: DigitalCart, action: String) {
        var categoryName = ""
        var labelName = ""
        
        categoryName = "\(GA_EVENT_CATEGORY_RECHARGE) - \(cart.categoryName)"
        labelName = "\(cart.operatorName) - \(cart.priceText)"
        
        AnalyticsManager.trackEventName(event.rawValue, category: categoryName, action: action, label: labelName)
    }
    
    static func trackRechargeEvent(event: DigitalEventName, category: PulsaCategory?, operators: PulsaOperator?, product: PulsaProduct?, action: String) {
        var categoryName = ""
        var operatorName = ""
        var productName = ""
        var labelName = ""
        
        if let cat = category {
            if !cat.attributes.name.isEmpty {
                categoryName = "\(GA_EVENT_CATEGORY_RECHARGE) - \(cat.attributes.name)"
                labelName = "\(cat.attributes.name)"
            }
        }
        
        if let oper = operators {
            if !oper.attributes.name.isEmpty {
                operatorName = oper.attributes.name
                labelName = "\(operatorName)"
            }
        }
        
        if let prod = product {
            if !prod.attributes.price.isEmpty {
                productName = prod.attributes.price
                labelName = "\(operatorName) - \(productName)"
            }
        }
        
        AnalyticsManager.trackEventName(event.rawValue, category: categoryName, action: action, label: labelName)
    }
    
    static func trackRechargeEvent(event: DigitalEventName, category: String, action: String) {
        let categoryName = "\(GA_EVENT_CATEGORY_RECHARGE) - \(category)"
        let labelName = category
        
        AnalyticsManager.trackEventName(event.rawValue, category: categoryName, action: action, label: labelName)
    }
    
    static func trackRechargeEvent(event: DigitalEventName, category: String, action: String, label: String) {
        let categoryName = "\(GA_EVENT_CATEGORY_RECHARGE) - \(category)"
        
        AnalyticsManager.trackEventName(event.rawValue, category: categoryName, action: action, label: label)
    }
    
    static func trackDigitalProductAddToCart(category: PulsaCategory, operators: PulsaOperator, product: PulsaProduct, isInstant: Bool) {
        let manager = AnalyticsManager()
        var data = [
            "event": "addToCart",
            "ecommerce": [
                "currencyCode": "IDR",
                "add": [
                    "products": [[
                        "name": "\(category.attributes.name) \(operators.attributes.name)",
                        "id": product.id,
                        "price": product.attributes.price,
                        "brand": operators.attributes.name,
                        "category": category.attributes.name,
                        "variant": "\(operators.attributes.name) \(product.attributes.price)",
                        "quantity": 1
                    ]]
                ]
            ]
        ] as [String: Any]
        if isInstant {
            data["cd3"] = "Bayar Instant"
        }
        manager.dataLayer.push(data)
    }
}
