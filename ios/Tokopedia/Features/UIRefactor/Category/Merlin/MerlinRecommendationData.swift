//
//  ProductCategoryPrediction.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

struct MerlinRecommendationData {
    let productCategoryPrediction: [ProductCategoryPrediction]
}

extension MerlinRecommendationData: Unboxable {
    init(unboxer: Unboxer) throws {
        self.productCategoryPrediction = try unboxer.unbox(keyPath: "product_category_prediction")
    }
}
