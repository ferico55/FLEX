//
//  MerlinProductCategory.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

struct MerlinProductCategory {
    let categoryId: String
    let name: String
}

extension MerlinProductCategory: Unboxable {
    init(unboxer: Unboxer) throws {
        self.categoryId = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
    }
}
