//
//  FeedAnalyticsManager.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 1/22/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    static func trackFeedProductClick(card: FeedCardProductState, position: Int) {
        if !card.isCampaign {
            let manager = AnalyticsManager()
            let eventLabel = card.isRecommendationProduct ? "inspirasi - \(card.recommendationProductSource)" : "product upload"
            let data = [
                "event": "productClick",
                "eventCategory": "homepage",
                "eventAction": "feed - click card item",
                "eventLabel": eventLabel,
                "ecommerce": [
                    "click": [
                        "actionField": [
                            "list": "/feed - product \(String(card.row)) - \(eventLabel)"
                        ],
                        "products": [[
                            "name": card.productName,
                            "id": card.productID,
                            "price": String(card.productPriceAmount),
                            "brand": "none / other",
                            "variant": "none / other",
                            "list": "/feed - product \(String(card.row)) - \(eventLabel)",
                            "position": String(position + 1),
                            "userId": UserAuthentificationManager().getUserId()
                        ]]
                    ]
                ]
            ] as [String: Any]
            manager.dataLayer.push(data)
        }
    }
    
    static func trackFeedImpression(card: FeedCardState) {
        let manager = AnalyticsManager()
        var eventLabel = ""
        if card.content.product.count > 0 ||
            (card.content.inspiration != nil && (card.content.inspiration?.products.count)! > 0) {
            // impression product
            let products = card.content.product
            var dictProduct = products.map { productData -> [String: Any] in
                guard let product = productData else { return [:] }
                var dict = [String: Any]()
                eventLabel = "product upload"
                dict["name"] = product.productName
                dict["id"] = product.productID
                dict["price"] = String(product.productPriceAmount)
                dict["brand"] = "none / other"
                dict["list"] = "/feed - product \(String(card.row)) - \(eventLabel)"
                dict["variant"] = "none / other"
                dict["position"] = String(product.position + 1)
                dict["userId"] = UserAuthentificationManager().getUserId()
                return dict
            }
            
            if let inspiration = card.content.inspiration?.products {
                dictProduct = inspiration.map { inspirasi -> [String: Any] in
                    guard let inspiration = inspirasi else { return [:] }
                    var dict = [String: Any]()
                    eventLabel = "inspirasi - \(inspiration.recommendationProductSource)"
                    dict["name"] = inspiration.productName
                    dict["id"] = inspiration.productID
                    dict["price"] = String(inspiration.productPriceAmount)
                    dict["brand"] = "none / other"
                    dict["list"] = "/feed - product \(String(card.row)) - \(eventLabel)"
                    dict["variant"] = "none / other"
                    dict["position"] = String(inspiration.position + 1)
                    dict["userId"] = UserAuthentificationManager().getUserId()
                    return dict
                }
            }
            
            let data = [
                "event": "productView",
                "eventCategory": "homepage",
                "eventAction": "feed - item impression",
                "eventLabel": eventLabel,
                "ecommerce": [
                    "currencyCode": "IDR",
                    "impressions": dictProduct
                ]
            ] as [String: Any]
            manager.dataLayer.push(data)
        }
    }
    
    static func trackKOLImpression(cardContent: FeedCardContentState) {
        let manager = AnalyticsManager()
        
        let eventDataLayer = [
            "event": "InternalPromo",
            "eventCategory": "Internal Promotion",
            "eventAction": "view",
            "eventLabel": cardContent.typeString
        ]
        
        if let userID = UserAuthentificationManager().getUserId(), let userInt = Int(userID) {
            let userIDModulo = userInt % 50
            
            var eCommerceDataLayer = [:] as [String: Any]
            
            if let kolPost = cardContent.kolPost {
                eCommerceDataLayer = [
                    "userId": userID,
                    "userIdmodulo": userIDModulo,
                    "ecommerce": [
                        "promoView": [
                            "promotions": [[
                                "id": kolPost.cardID,
                                "name": "/content feed - \(kolPost.contentType) - \(kolPost.tagType)",
                                "creative": kolPost.userName,
                                "position": "\(kolPost.row)",
                                "category": kolPost.userInfo,
                                "promo_id": kolPost.tagID,
                                "promo_code": kolPost.tagURL
                            ]]
                        ]
                    ]
                ]
            } else if let kolRecommendation = cardContent.kolRecommendation {
                let kolUsers = kolRecommendation.users.map { user in
                    return [
                        "id": user.userID,
                        "name": "/content feed - kolrecommendation - profile",
                        "creative": user.userName,
                        "position": "\(kolRecommendation.row)",
                        "category": user.userInfo,
                        "promo_id": user.userID,
                        "promo_code": user.userURL
                    ]
                }
                
                eCommerceDataLayer = [
                    "userId": userID,
                    "userIdmodulo": userIDModulo,
                    "ecommerce": [
                        "promoView": [
                            "promotions": kolUsers
                        ]
                    ]
                ]
            }
            
            manager.dataLayer.push(eventDataLayer)
            manager.dataLayer.push(eCommerceDataLayer)
        }
    }
    
    static func trackKOLClick(cardContent: FeedCardContentState, index: Int) {
        let manager = AnalyticsManager()
        
        let eventDataLayer = [
            "event": "InternalPromo",
            "eventCategory": "Internal Promotion",
            "eventAction": "click",
            "eventLabel": cardContent.typeString
        ]
        
        if let userID = UserAuthentificationManager().getUserId(), let userInt = Int(userID) {
            let userIDModulo = userInt % 50
            
            var eCommerceDataLayer = [:] as [String: Any]
            
            if let kolPost = cardContent.kolPost {
                eCommerceDataLayer = [
                    "event": "promoClick",
                    "userId": userID,
                    "userIdmodulo": userIDModulo,
                    "ecommerce": [
                        "promoClick": [
                            "promotions": [[
                                "id": kolPost.cardID,
                                "name": "/content feed - \(kolPost.contentType) - \(kolPost.tagType)",
                                "creative": kolPost.userName,
                                "position": "\(cardContent.row)",
                                "category": kolPost.userInfo,
                                "promo_id": kolPost.tagID,
                                "promo_code": kolPost.tagURL
                            ]]
                        ]
                    ]
                ]
            } else if let kolRecommendation = cardContent.kolRecommendation {
                let selectedUser = kolRecommendation.users[index]
                eCommerceDataLayer = [
                    "event": "promoClick",
                    "userId": userID,
                    "userIdmodulo": userIDModulo,
                    "ecommerce": [
                        "promoClick": [
                            "promotions": [[
                                "id": selectedUser.userID,
                                "name": "/content feed - kolrecommendation - profile",
                                "creative": selectedUser.userName,
                                "position": "\(kolRecommendation.row)",
                                "category": selectedUser.userInfo,
                                "promo_id": selectedUser.userID,
                                "promo_code": selectedUser.userURL
                            ]]
                        ]
                    ]
                ]
            }
            
            manager.dataLayer.push(eventDataLayer)
            manager.dataLayer.push(eCommerceDataLayer)
        }
    }
}
