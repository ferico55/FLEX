//
//  AnalyticsManager.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 12/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//
import Foundation

extension AnalyticsManager {
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
