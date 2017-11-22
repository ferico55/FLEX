//
//  FuzzySearchProduct.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchProduct)
final class FuzzySearchProduct: NSObject, Unboxable {
    var productId: String = "0"
    var name: String?
    var URL: String?
    var imageURL: String?
    var imageURL700: String?
    var price: String?
    var condition: Int = 0
    var departmentId: String?
    var rating: Int = 0
    var countReview: Int = 0
    var originalPrice: String?
    var discountExpired: String?
    var discountPercentage: Int?
    var badges: [ProductBadge]?
    var wholesalePrice: [FuzzyWholesalePrice]?
    var labels: [ProductLabel]?
    var shop: FuzzySearchShop?
    var isOnWishlist: Bool = false
    
    var viewModel:ProductModelView {
        get {
            let vm = ProductModelView()
            vm.productName = name
            vm.productPrice = price
            vm.productShop = shop?.name
            vm.productThumbUrl = imageURL
            vm.productReview = String(countReview)
            vm.isGoldShopProduct = shop?.isGold ?? false
            vm.shopLocation = self.shop?.location
            vm.isWholesale = wholesalePrice != nil ? true : false
            vm.badges = badges
            vm.labels = labels
            vm.productLargeUrl = self.imageURL700
            vm.isOnWishlist = self.isOnWishlist
            vm.productId = productId
            vm.productRate = String(rating)
            vm.totalReview = String(countReview)
            return vm
        }
    }
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.productId = try unboxer.unbox(keyPath: "id")
        self.name = try? unboxer.unbox(keyPath: "name")
        self.URL = try? unboxer.unbox(keyPath: "url")
        self.imageURL = try? unboxer.unbox(keyPath: "image_url")
        self.imageURL700 = try? unboxer.unbox(keyPath: "image_url_700")
        self.price = try? unboxer.unbox(keyPath: "price")
        self.condition = try unboxer.unbox(keyPath: "condition")
        self.departmentId = try? unboxer.unbox(keyPath: "department_id")
        self.rating = try unboxer.unbox(keyPath: "rating")
        self.countReview = try unboxer.unbox(keyPath: "count_review")
        self.originalPrice = try? unboxer.unbox(keyPath: "original_price")
        self.discountExpired = try? unboxer.unbox(keyPath: "discount_expired")
        self.discountPercentage = try? unboxer.unbox(keyPath: "discount_percentage")
        self.badges = try? unboxer.unbox(keyPath: "badges")
        self.wholesalePrice = try? unboxer.unbox(keyPath: "wholesale_price")
        self.labels = try? unboxer.unbox(keyPath: "labels")
        self.shop = try? unboxer.unbox(keyPath: "shop")
    }
    
    func productFieldObjects() -> [String:String] {
        let characterSet = CharacterSet(charactersIn: "Rp.")
        let productPriceArray = price?.components(separatedBy: characterSet)
        let productPrice = productPriceArray?.joined(separator: "")
        return [
            "name"  : name!,
            "id"    : String(productId),
            "price" : productPrice!,
            "brand" : (shop?.name!)!,
            "url"   : URL!
        ]
    }
}

@objc(FuzzySearchShop)
final class FuzzySearchShop: NSObject, Unboxable {
    var shopId: String = ""
    var name: String?
    var URL: String?
    var isGold: Bool = false
    var location: String?
    var city: String?
    var reputation: String?
    var clover: String?
    
    required override init() {
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.shopId = try unboxer.unbox(keyPath: "id")
        self.name = try? unboxer.unbox(keyPath: "name")
        self.URL = try? unboxer.unbox(keyPath: "url")
        self.isGold = try unboxer.unbox(keyPath: "is_gold")
        self.location = try? unboxer.unbox(keyPath: "location")
        self.city = try? unboxer.unbox(keyPath: "city")
        self.reputation = try? unboxer.unbox(keyPath: "reputation")
        self.clover = try? unboxer.unbox(keyPath: "clover")
    }
}

@objc(FuzzyWholesalePrice)
final class FuzzyWholesalePrice: NSObject, Unboxable {
    var quantityMin: Int = 0
    var quantityMax: Int = 0
    var price: String = ""
    
    required override init() {
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
            self.quantityMin = try unboxer.unbox(keyPath: "quantity_min")
            self.quantityMax = try unboxer.unbox(keyPath: "quantity_max")
            self.price = try unboxer.unbox(keyPath: "price")
    }
}
