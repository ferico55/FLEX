//
//  ProductDetailAnalyticsManager.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 1/22/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    static func trackProductView(product: ProductUnbox) {
        let manager = AnalyticsManager()
        let shopType = product.shop.isOfficial ? "official_store" : product.shop.isGoldMerchant ? "gold_merchant" : "regular"
        let category = product.categories.flatMap({ $0.name }).joined(separator: "/")
        let data = [
            "event": "viewProduct",
            "eventCategory": "product page",
            "eventAction": "view product page",
            "eventLabel": "\(shopType) - \(product.shop.name) - \(product.name)",
            "ecommerce": [
                "currencyCode": "IDR",
                "detail": [
                    "products": [[
                        "name": product.name,
                        "id": product.id,
                        "price": product.info.priceUnformatted,
                        "brand": "none / other",
                        "category": category,
                        "variant": "none / other"
                    ]]
                ]
            ],
            "key": product.key,
            "shop_name": product.shop.name,
            "shop_id": product.shop.id,
            "shop_domain": product.shop.domain,
            "shop_location": product.shop.location,
            "shop_is_gold": product.shop.isGoldMerchant,
            "category_id": product.lastLevelCategory().id,
            "url": product.url,
            "picture": product.images.first?.normalURL,
            "short_desc": product.info.description,
            "shop_type": shopType
        ] as [String: Any]

        manager.dataLayer.push(data)
    }
}
