//
//  CategoryIntermediaryCuratedProductSection.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CategoryIntermediaryCuratedProductSection: NSObject, Unboxable {
    var title: String = ""
    var products: [CategoryIntermediaryProduct]
    
    required convenience init(unboxer:Unboxer) throws {
        self.init(
            title: try unboxer.unbox(keyPath: "title"),
            products: try unboxer.unbox(keyPath: "products")
        )
    }
    
    init(title: String, products: [CategoryIntermediaryProduct]) {
        self.title = title
        self.products = products
    }
}
