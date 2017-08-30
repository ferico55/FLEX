//
//  FeaturedProduct.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(FeaturedProduct)
final class FeaturedProduct: NSObject, Unboxable {
    let productID:String!
    let name:String!
    let uri: String!
    let price: String!
    let imageUri: String!
    let preorder: Bool!
    let returnable: Bool!
    let wholesale: Bool!
    let cashback: Bool!
    let cashbackDetail: CashbackDetail!
    let labels: [ProductLabel]?
    let badges: [ProductBadge]?
    
    var viewModel: ProductModelView {
        let vm = ProductModelView()
        vm.productName = name
        vm.productPrice = price
        vm.productThumbUrl = imageUri
        vm.isProductPreorder = preorder
        vm.isWholesale = wholesale
        vm.productId = productID
        vm.badges = badges
        vm.labels = labels
        return vm
    }
    
    init(productID:String, name:String, uri:String, price: String, imageUri:String, preorder: Bool, returnable: Bool, wholesale: Bool, cashback:Bool, cashbackDetail: CashbackDetail, labels: [ProductLabel]?, badges: [ProductBadge]?) {
        self.productID = productID
        self.name = name
        self.uri = uri
        self.price = price
        self.imageUri = imageUri
        self.preorder = preorder
        self.returnable = returnable
        self.wholesale = wholesale
        self.cashback = cashback
        self.cashbackDetail = cashbackDetail
        self.labels = labels
        self.badges = badges
    }
    
    convenience init(unboxer: Unboxer) throws {
        self.init(
            productID: try unboxer.unbox(keyPath: "product_id"),
            name:try unboxer.unbox(keyPath: "name"),
            uri: try unboxer.unbox(keyPath: "uri"),
            price: try unboxer.unbox(keyPath: "price"),
            imageUri: try unboxer.unbox(keyPath: "image_uri"),
            preorder: try unboxer.unbox(keyPath: "preorder"),
            returnable: try unboxer.unbox(keyPath: "returnable"),
            wholesale: try unboxer.unbox(keyPath: "wholesale"),
            cashback: try unboxer.unbox(keyPath: "cashback"),
            cashbackDetail: try unboxer.unbox(keyPath: "cashback_detail") as CashbackDetail,
            labels: try? unboxer.unbox(keyPath: "labels") as [ProductLabel],
            badges: try? unboxer.unbox(keyPath: "badges") as [ProductBadge]
        )
    }
    
    func productFieldObjects() -> [String:String] {
        let characterSet = CharacterSet(charactersIn: "Rp.")
        let productPriceArray = self.price.components(separatedBy: characterSet)
        let productPrice = productPriceArray.joined(separator: "")
        return [
            "name"  : self.name!,
            "id"    : String(self.productID),
            "price" : price!,
            "url"   : self.uri!
        ]
    }
}
