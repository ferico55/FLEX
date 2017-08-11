//
//  ShopProductPageListSwift.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(ShopProductPageList)
final class ShopProductPageList: NSObject, Unboxable {
    let shop_lucky: String
    let shop_gold_status: String
    let shop_id: String
    let shop_url: String
    let product_id: String
    let product_talk_count: String
    let product_image: String
    var product_price: String = ""
    let shop_location: String
    let product_image_300: String
    let product_image_700: String
    let shop_name: String
    let product_review_count: String
    let product_url: String
    let product_name: String
    var original_price: String?
    var end_date: String?
    var percentage_amount: Int?
    let badges: [ProductBadge]?
    let labels: [ProductLabel]?
    let product_wholesale: Int
    let product_preorder: Int
    var isOnWishlist = false
    var is_product_preorder: Bool {
        return product_preorder == 1
    }
    var is_product_wholesale: Bool {
        return product_wholesale == 1
    }
    var viewModel: ProductModelView {
        let vm = ProductModelView()
        vm.productName = product_name
        vm.productPrice = product_price
        vm.original_price = original_price
        vm.productThumbUrl = product_image
        vm.productReview = product_review_count
        vm.productTalk = product_talk_count
        vm.isGoldShopProduct = shop_gold_status == "1"
        vm.luckyMerchantImageURL = shop_lucky
        vm.isProductPreorder = product_preorder == 1
        vm.isWholesale = is_product_wholesale
        vm.productLargeUrl = product_image_700
        vm.isOnWishlist = isOnWishlist
        vm.productId = product_id
        if let amount = self.percentage_amount {
            vm.percentage_amount = amount
        } else {
            vm.percentage_amount = 0
        }
        return vm
        
    }
    
    init(shop_lucky: String,
         shop_gold_status: String,
         shop_id: String,
         shop_url: String,
         product_id: String,
         product_talk_count: String,
         product_image: String,
         product_price: String,
         shop_location: String,
         product_image_300: String,
         product_image_700: String,
         shop_name: String,
         product_review_count: String,
         product_url: String,
         product_name: String,
         badges: [ProductBadge]?,
         labels: [ProductLabel]?,
         product_wholesale: Int,
         product_preorder: Int) {
        self.shop_lucky = shop_lucky
        self.shop_gold_status = shop_gold_status
        self.shop_id = shop_id
        self.shop_url = shop_url
        self.product_id = product_id
        self.product_talk_count = product_talk_count
        self.product_image = product_image
        self.product_price = product_price
        self.shop_location = shop_location
        self.product_image_300 = product_image_300
        self.product_image_700 = product_image_700
        self.shop_name = shop_name
        self.product_review_count = product_review_count
        self.product_url = product_url
        self.product_name = product_name
        self.badges = badges
        self.labels = labels
        self.product_wholesale = product_wholesale
        self.product_preorder = product_preorder
    }
    
    convenience init(unboxer: Unboxer) throws {
        self.init(
            shop_lucky: try unboxer.unbox(keyPath: "shop_lucky"),
            shop_gold_status: try unboxer.unbox(keyPath: "shop_gold_status"),
            shop_id: try unboxer.unbox(keyPath: "shop_id"),
            shop_url: try unboxer.unbox(keyPath: "shop_url"),
            product_id: try unboxer.unbox(keyPath: "product_id"),
            product_talk_count: try unboxer.unbox(keyPath: "product_talk_count"),
            product_image: try unboxer.unbox(keyPath: "product_image"),
            product_price: try unboxer.unbox(keyPath: "product_price"),
            shop_location: try unboxer.unbox(keyPath: "shop_location"),
            product_image_300: try unboxer.unbox(keyPath: "product_image_300"),
            product_image_700: try unboxer.unbox(keyPath: "product_image_700"),
            shop_name: try unboxer.unbox(keyPath: "shop_name"),
            product_review_count: try unboxer.unbox(keyPath: "product_review_count"),
            product_url: try unboxer.unbox(keyPath: "product_url"),
            product_name: try unboxer.unbox(keyPath: "product_name"),
            badges: try? unboxer.unbox(keyPath: "badges") as [ProductBadge],
            labels: try? unboxer.unbox(keyPath: "labels") as [ProductLabel],
            product_wholesale: try unboxer.unbox(keyPath: "product_wholesale"),
            product_preorder: try unboxer.unbox(keyPath: "product_preorder")
        )
    }
    
    func productFieldObjects() -> [AnyHashable: Any] {
        let characterSet = CharacterSet(charactersIn: "Rp.")
        let productPrice = product_price.components(separatedBy: characterSet)
        let price = productPrice.joined(separator: "")
        return [
            "name": self.product_name,
            "id": self.product_id,
            "price": price,
            "brand": self.shop_name,
            "url": self.product_url
        ]
    }
}
