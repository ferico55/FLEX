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
    var products: [CategoryIntermediaryProduct]!
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.title = try unboxer.unbox(keyPath: "title");
        self.products = try unboxer.unbox(keyPath: "products");
    }
}
