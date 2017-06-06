//
//  ProductModelView.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class ProductModelViewSwift : NSObject {
    
    var productName:String? {
        get {
            return productName?.kv_decodeHTMLCharacterEntities()
        }
        set {
            productName = newValue
        }
    }
    var productPrice:String?
    var productPriceIDR:String?
    var productShop:String? {
        get{
            return productShop?.kv_decodeHTMLCharacterEntities()
        }
        set {
            productName = newValue
        }
    }
    var shopLocation:String?
    var productThumbUrl:String?
    var productLargeUrl:String?
    var singleGridImageUrl:String?
    var productReview:String?
    var productTalk:String?
    var luckyMerchantImageURL:String?
    var productDescription:String?
    
    var productPriceBeforeChange:String?
    var productQuantity:String?
    var productTotalWeight:String?
    var productNotes:String?
    var productErrorMessage:String?
    var badges:[ProductBadge] = []
    var labels:[ProductLabel] = []
    
    var productErrors:[ErrorsSwift] = []
    var cartErrors:[ErrorsSwift] = []
    var preorder:ProductPreorder?
    var isProductBuyAble = false
    var isGoldShopProduct = false
    var isWholesale = false
    var isProductPreorder = false
    
//    func productName() -> String {
//        return productName.kv_decodeHTMLCharacterEntities();
//    }
    
//    func productShop() -> String {
//        return productShop.kv_decodeHTMLCharacterEntities();
//    }
    
//    func singleGridImageUrl() -> String {
//        return self.productLargeUrl ? self.productLargeUrl : self.productThumbUrl
//    }
}
