//
//  CategoryIntermediaryCuratedProduct.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CategoryIntermediaryCuratedProduct: NSObject, Unboxable {
    var categoryId: Int = 0
    var sections: [CategoryIntermediaryCuratedProductSection]?
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.categoryId = try unboxer.unbox(keyPath: "category_id")
        self.sections = try? unboxer.unbox(keyPath: "sections") as [CategoryIntermediaryCuratedProductSection]
    }
}
