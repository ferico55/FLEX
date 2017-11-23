//
//  MerlinRecommendation.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

struct MerlinRecommendationResponse {
    let data: [MerlinRecommendationData]
}

extension MerlinRecommendationResponse: Unboxable {
    init(unboxer: Unboxer) throws {
        self.data = try unboxer.unbox(keyPath: "data")
    }
}
