//
//  OfficialStoreHomeItem.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 6/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc
final class OfficialStoreHomeItem: NSObject, Unboxable {
    let shopId: String
    let imageUrl: String
    let shopName: String
    let shopUrl: String
    let isNew: Bool
    
    init(shopId:String,
         imageUrl:String,
         shopName:String,
         shopUrl:String?,
         isNew:Int) {
        self.shopId = shopId
        self.imageUrl = imageUrl
        self.shopName = shopName
        self.shopUrl = shopUrl ?? ""
        self.isNew = isNew == 1
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            shopId: try unboxer.unbox(keyPath:"shop_id"),
            imageUrl: try unboxer.unbox(keyPath:"logo_url"),
            shopName: try unboxer.unbox(keyPath:"shop_name"),
            shopUrl: try? unboxer.unbox(keyPath:"shop_url") as String,
            isNew: try unboxer.unbox(keyPath:"is_new")
        )
    }
}
