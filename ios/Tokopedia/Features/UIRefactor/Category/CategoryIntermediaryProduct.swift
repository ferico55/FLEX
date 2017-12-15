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
    var badges: [ProductBadge]
    var name: String = ""
    var price: String = ""
    var rating: Int = 0
    var url: String = ""
    var wholesalePrice: String? = ""
    var labels: [ProductLabel]
    var shop: CategoryIntermediaryProductShop
    var applinks: String = ""
    var isOnWishlist = false

    required convenience init(unboxer:Unboxer) throws {
        self.init(
            id: try unboxer.unbox(keyPath: "id"),
            departmentId: try unboxer.unbox(keyPath: "department_id"),
            condition: try unboxer.unbox(keyPath: "condition"),
            imageUrl: try unboxer.unbox(keyPath: "image_url"),
            badges: try unboxer.unbox(keyPath: "badges"),
            name: try unboxer.unbox(keyPath: "name"),
            price: try unboxer.unbox(keyPath: "price"),
            rating: try unboxer.unbox(keyPath: "rating"),
            url: try unboxer.unbox(keyPath: "url"),
            wholesalePrice: try? unboxer.unbox(keyPath: "wholesale_price") as String,
            labels: try unboxer.unbox(keyPath: "labels"),
            shop: try unboxer.unbox(keyPath: "shop"),
            appLinks: try unboxer.unbox(keyPath: "applinks")
        )
    }
    
    init(id: String, departmentId: Int, condition: Int, imageUrl: String, badges: [ProductBadge], name: String, price: String, rating: Int, url: String, wholesalePrice: String?, labels: [ProductLabel], shop: CategoryIntermediaryProductShop, appLinks: String) {
        self.id = id
        self.departmentId = departmentId
        self.condition = condition
        self.imageUrl = imageUrl
        self.badges = badges
        self.name = name
        self.price = price
        self.rating = rating
        self.url = url
        self.wholesalePrice = wholesalePrice
        self.labels = labels
        self.shop = shop
        self.applinks = appLinks
    }
}
