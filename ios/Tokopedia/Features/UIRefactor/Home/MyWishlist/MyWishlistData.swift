//
//  MyWishlistData.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

@objc(MyWishlistData)
class MyWishlistData: NSObject {
    var id: String!
    var name: String!
    var url: String!
    var image: String!
    var price: NSNumber!
    var price_formatted: String!
    var minimum_order: NSNumber!
    var wholesale_price: [MyWishlistWholesalePrice]!
    var condition: String!
    var shop: MyWishlistShop!
    var badges: [ProductBadge] = []
    var labels: [ProductLabel]!
    var available: Bool = false
    var status: String!
    var preorder: Bool = false
    
    var productModelView: ProductModelView!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: MyWishlistData.self)
        
        mapping?.addAttributeMappings(from:["id", "name", "url", "image", "price", "price_formatted", "minimum_order", "condition", "available", "status", "preorder"])
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "wholesale_price", toKeyPath: "wholesale_price", with: MyWishlistWholesalePrice.mapping()))
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "shop", toKeyPath: "shop", with: MyWishlistShop.mapping()))
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "badges", toKeyPath: "badges", with: ProductBadge.mapping()))
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "labels", toKeyPath: "labels", with: ProductLabel.mapping()))
        
        return mapping!
    }
    
    func viewModel() -> ProductModelView {
        if self.productModelView == nil {
            let productModelView = ProductModelView()
            productModelView.productName = self.name
            productModelView.productPrice = self.price_formatted
            productModelView.productShop = self.shop.name
            productModelView.productThumbUrl = self.image
            productModelView.isGoldShopProduct = self.shop.gold_merchant
            productModelView.isProductBuyAble = self.available
            
            var isProductWholesale = false
            if self.wholesale_price != nil {
                isProductWholesale = true
            }
            
            productModelView.isWholesale = isProductWholesale
            productModelView.isProductPreorder = self.preorder
            productModelView.shopLocation = self.shop.location
            productModelView.badges = self.badges
            productModelView.labels = self.labels
            
            self.productModelView = productModelView
        }
        
        return self.productModelView
    }

    func productFieldObjects() -> NSDictionary{
        let productFieldObjects = [
            "name" : self.name,
            "id" : self.id,
            "price" : self.price,
            "brand" : self.shop.name] as [String : Any]
        return productFieldObjects as NSDictionary
    }
}
