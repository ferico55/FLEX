//
//  ProductCategoryPrediction.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

struct ProductCategoryPrediction {
    let merlinProductCategories: [MerlinProductCategory]
}

extension ProductCategoryPrediction: Unboxable {
    init(unboxer: Unboxer) throws {
        self.merlinProductCategories = try unboxer.unbox(keyPath: "product_category_id")
    }
}
