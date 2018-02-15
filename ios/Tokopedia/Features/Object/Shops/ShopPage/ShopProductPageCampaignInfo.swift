//
//  ShopProductPageCampaignInfo.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON
import Unbox

internal final class ShopProductPageCampaignInfo: Unboxable {
    internal let productID: String
    internal let discountedPrice: String
    internal let endDate: String
    internal let originalPrice: String
    internal let percentageAmount: Int

    internal init(productID: String, discountedPrice: String, endDate: String, originalPrice: String, percentageAmount: Int) {
        self.productID = productID
        self.discountedPrice = discountedPrice
        self.endDate = endDate
        self.originalPrice = originalPrice
        self.percentageAmount = percentageAmount
    }

    convenience internal init(unboxer: Unboxer) throws {
        self.init(
            productID: try unboxer.unbox(keyPath: "product_id"),
            discountedPrice: try unboxer.unbox(keyPath: "discounted_price"),
            endDate: try unboxer.unbox(keyPath: "end_date"),
            originalPrice: try unboxer.unbox(keyPath: "original_price_idr"),
            percentageAmount: try unboxer.unbox(keyPath: "percentage_amount")
        )
    }
}
