//
//  CategoryIntermediaryProduct.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CategoryIntermediaryProduct: NSObject, Unboxable {
    var id: String = ""
    var departmentId: Int = 0
    var condition: Int = 0
    var imageUrl: String = ""
    var badges: [ProductBadge]!
    var name: String = ""
    var price: String = ""
    var rating: Int = 0
    var url: String = ""
    var wholesalePrice: String? = ""
    var labels: [ProductLabel]!
    var shop: CategoryIntermediaryProductShop!
    var applinks: String = ""
    var isOnWishlist = false

    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.id = try unboxer.unbox(keyPath: "id")
        self.condition = try unboxer.unbox(keyPath: "condition")
        self.name = try unboxer.unbox(keyPath: "name")
        self.price = try unboxer.unbox(keyPath: "price")
        self.rating = try unboxer.unbox(keyPath: "rating")
        self.url = try unboxer.unbox(keyPath: "url")
        self.applinks = try unboxer.unbox(keyPath: "applinks")
        self.departmentId = try unboxer.unbox(keyPath: "department_id")
        self.imageUrl = try unboxer.unbox(keyPath: "image_url")
        self.wholesalePrice = try? unboxer.unbox(keyPath: "wholesale_price") as String
        self.badges = try unboxer.unbox(keyPath: "badges")
        self.labels = try unboxer.unbox(keyPath: "labels")
        self.shop = try unboxer.unbox(keyPath: "shop")
    }
}
