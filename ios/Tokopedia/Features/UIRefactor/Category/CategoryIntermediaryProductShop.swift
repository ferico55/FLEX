//
//  CategoryIntermediaryProductShop.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CategoryIntermediaryProductShop: NSObject, Unboxable {
    var city: String = ""
    var clover: String = ""
    var id: Int = 0
    var isGold: Bool = false
    var location: String = ""
    var name: String = ""
    var reputation: String = ""
    var url: String = ""
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.city = try unboxer.unbox(keyPath: "city")
        self.clover = try unboxer.unbox(keyPath: "clover")
        self.location = try unboxer.unbox(keyPath: "location")
        self.id = try unboxer.unbox(keyPath: "id")
        self.name = try unboxer.unbox(keyPath: "name")
        self.reputation = try unboxer.unbox(keyPath: "reputation")
        self.url = try unboxer.unbox(keyPath: "url")
        self.isGold = try unboxer.unbox(keyPath: "is_gold")
    }
}
