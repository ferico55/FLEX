//
//  ProductWishlistCheckResult.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ProductWishlistCheckResult:Unboxable {
    let ids:[String]
    
    init(ids:[String]) {
        self.ids = ids
    }
    
    convenience init(unboxer: Unboxer) throws {
        let ids = try unboxer.unbox(keyPath: "data.ids") as [String]
        
        self.init(ids:ids)
    }
}
