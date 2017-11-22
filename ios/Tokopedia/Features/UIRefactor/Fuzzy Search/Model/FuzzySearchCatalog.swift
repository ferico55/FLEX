//
//  FuzzySearchCatalog.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchCatalog)
final class FuzzySearchCatalog: NSObject, Unboxable {
    var catalogId: String = "0"
    var name: String?
    var price: String?
    var priceMin: String?
    var priceMax: String?
    var countProduct: Int = 0
    var desc: String?
    var imageURL: String?
    var URL: String?
    var departmentId: String?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.catalogId = try unboxer.unbox(keyPath: "id")
        self.name = try? unboxer.unbox(keyPath: "name")
        self.price = try? unboxer.unbox(keyPath: "price")
        self.priceMin = try? unboxer.unbox(keyPath: "price_min")
        self.priceMax = try? unboxer.unbox(keyPath: "price_max")
        self.countProduct = try unboxer.unbox(keyPath: "count_product")
        self.desc = try? unboxer.unbox(keyPath: "description")
        self.imageURL = try? unboxer.unbox(keyPath: "image_url")
        self.URL = try? unboxer.unbox(keyPath: "url")
        self.departmentId = try? unboxer.unbox(keyPath: "department_id")
        
    }
}
