//
//  ShopProductPageCampaignInfo.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class ShopProductPageCampaignInfo : Unboxable {
    let product_id:String
    let discounted_price:String
    let end_date:String
    let original_price:String
    let percentage_amount: Int
    
    init(product_id: String, discounted_price:String, end_date:String, original_price:String, percentage_amount:Int) {
        self.product_id = product_id
        self.discounted_price = discounted_price
        self.end_date = end_date
        self.original_price = original_price
        self.percentage_amount = percentage_amount
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            product_id: try unboxer.unbox(keyPath:"product_id"),
            discounted_price: try unboxer.unbox(keyPath:"discounted_price"),
            end_date: try unboxer.unbox(keyPath:"end_date"),
            original_price: try unboxer.unbox(keyPath:"original_price_idr"),
            percentage_amount: try unboxer.unbox(keyPath:"percentage_amount")
        )
    }
}
