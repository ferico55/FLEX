//
//  ProductWishlistStatus.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ProductWishlistStatus: Unboxable {
    let productId: String
    let wishlisted: Bool
    
    init(productId: String, wishlisted: Bool) {
        self.productId = productId
        self.wishlisted = wishlisted
    }
    
    convenience init(unboxer: Unboxer) throws {
        let productId = try unboxer.unbox(keyPath: "product_id") as String
        let wishlisted = try unboxer.unbox(keyPath: "wishlisted") as Bool
        
        self.init(productId: productId, wishlisted: wishlisted)
    }
}
