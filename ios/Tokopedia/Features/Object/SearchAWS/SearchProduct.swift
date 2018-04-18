//
//  SearchProduct.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 6/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(SearchProduct)
final internal class SearchProduct:NSObject, Unboxable {
    internal let shop_gold_status:Int
    internal let product_sold_count:Int
    internal let discount_expired:String?
    internal var product_review_count:Int
    internal let product_wholesale:Int
    internal let is_owner:Int
    internal let product_image:String?
    internal let product_image_700:String?
    internal let preorder:Int
    internal let product_id:String
    internal let shop_location:String?
    internal let condition:Int
    internal let product_price:String?
    internal let product_image_full:String?
    internal var product_talk_count:Int
    internal let product_preorder:Int
    internal let original_price:String?
    internal let shop_url:String?
    internal var rate:Int
    internal let discount_percentage:Int
    internal let category_breadcrumb:String
    internal let shop_name:String?
    internal let category_id:String?
    internal let shop_id:Int
    internal let product_url:String?
    internal let product_name:String?
    internal var isOnWishlist = false
    internal var badges:[ProductBadge]?
    internal var labels:[ProductLabel]?
    internal var is_product_wholesale = false
    
    internal let catalog_id:String?
    internal let catalog_name:String?
    internal let catalog_price:String?
    internal let catalog_uri:String?
    internal let catalog_image:String?
    internal let catalog_image_300:String?
    internal let catalog_description:String?
    internal let catalog_count_product:String?
    
    internal var similarity_rank:String?
    
    internal var trackerInfo: NSDictionary = [:]
    
    internal var viewModel:ProductModelView {
        get {
            let vm = ProductModelView()
            vm.productName = self.product_name
            vm.productPrice = self.product_price
            vm.productShop = self.shop_name
            vm.productThumbUrl = self.product_image
            vm.productReview = String(self.product_review_count)
            vm.productTalk = String(self.product_talk_count)
            vm.isGoldShopProduct = self.shop_gold_status == 1
            vm.shopLocation = self.shop_location
            vm.isProductPreorder = self.product_preorder == 1
            vm.isWholesale = self.is_product_wholesale
            vm.badges = badges
            vm.labels = labels
            vm.productLargeUrl = self.product_image_700
            vm.isOnWishlist = self.isOnWishlist
            vm.productId = self.product_id
            vm.productRate = String(round(Double(self.rate) / 20.0))
            vm.totalReview = String(self.product_review_count)
            return vm
        }
    }
    internal var catalogViewModel:CatalogModelView {
        get {
            let vm = CatalogModelView()
            vm.catalogName = self.catalog_name
            vm.catalogPrice = self.catalog_price
            vm.catalogSeller = self.catalog_count_product
            vm.catalogThumbUrl = self.catalog_image_300
            return vm
        }
    }
    
    internal init(shop_gold_status:Int?,
         product_sold_count:Int?,
         discount_expired:String?,
         product_review_count:Int?,
         product_wholesale:Int?,
         is_owner:Int?,
         product_image:String?,
         product_image_700:String?,
         preorder:Int?,
         product_id:Int?,
         shop_location:String?,
         condition:Int?,
         product_price:String?,
         product_image_full:String?,
         product_talk_count:Int?,
         product_preorder:Int?,
         original_price:String?,
         shop_url:String?,
         rate:Int?,
         discount_percentage:Int?,
         category_breadcrumb:String?,
         shop_name:String?,
         category_id:String?,
         shop_id:Int?,
         product_url:String?,
         product_name:String?,
         badges:[ProductBadge]?,
         catalog_id:String?,
         catalog_name:String?,
         catalog_price:String?,
         catalog_uri:String?,
         catalog_image:String?,
         catalog_image_300:String?,
         catalog_description:String?,
         catalog_count_product:String?,
         labels:[ProductLabel]?) {
        self.shop_gold_status = shop_gold_status ?? 0
        self.product_sold_count = product_sold_count ?? 0
        self.discount_expired = discount_expired
        self.product_review_count = product_review_count ?? 0
        self.product_wholesale = product_wholesale ?? 0
        self.is_owner = is_owner ?? 0
        self.product_image = product_image
        self.product_image_700 = product_image_700
        self.preorder = preorder ?? 0
        self.product_id = String(product_id ?? 0)
        self.shop_location = shop_location
        self.condition = condition ?? 0
        self.product_price = product_price
        self.product_image_full = product_image_full
        self.product_talk_count = product_talk_count ?? 0
        self.product_preorder = product_preorder ?? 0
        self.original_price = original_price
        self.shop_url = shop_url
        self.rate = rate ?? 0
        self.discount_percentage = discount_percentage ?? 0
        self.category_breadcrumb = category_breadcrumb ?? ""
        self.shop_name = shop_name
        self.category_id = category_id
        self.shop_id = shop_id ?? 0
        self.product_url = product_url
        self.product_name = product_name
        self.badges = badges
        self.catalog_id = catalog_id
        self.catalog_name = catalog_name
        self.catalog_price = catalog_price
        self.catalog_uri = catalog_uri
        self.catalog_image = catalog_image
        self.catalog_image_300 = catalog_image_300
        self.catalog_description = catalog_description
        self.catalog_count_product = catalog_count_product
        self.labels = labels
    }
    
    convenience internal init(unboxer: Unboxer) throws {
        self.init(
            shop_gold_status : try? unboxer.unbox(keyPath: "shop_gold_status") as Int,
            product_sold_count : try? unboxer.unbox(keyPath: "product_sold_count") as Int,
            discount_expired : try? unboxer.unbox(keyPath: "discount_expired") as String,
            product_review_count : try? unboxer.unbox(keyPath: "product_review_count") as Int,
            product_wholesale : try? unboxer.unbox(keyPath: "product_wholesale") as Int,
            is_owner : try? unboxer.unbox(keyPath: "is_owner") as Int,
            product_image : try? unboxer.unbox(keyPath: "product_image") as String,
            product_image_700 : try? unboxer.unbox(keyPath: "product_image_700") as String,
            preorder : try? unboxer.unbox(keyPath: "preorder") as Int,
            product_id : try? unboxer.unbox(keyPath: "product_id") as Int,
            shop_location : try? unboxer.unbox(keyPath: "shop_location") as String,
            condition : try? unboxer.unbox(keyPath: "condition") as Int,
            product_price : try? unboxer.unbox(keyPath: "product_price") as String,
            product_image_full : try? unboxer.unbox(keyPath: "product_image_full") as String,
            product_talk_count : try? unboxer.unbox(keyPath: "product_talk_count") as Int,
            product_preorder : try? unboxer.unbox(keyPath: "product_preorder") as Int,
            original_price : try? unboxer.unbox(keyPath: "original_price") as String,
            shop_url : try? unboxer.unbox(keyPath: "shop_url") as String,
            rate : try? unboxer.unbox(keyPath: "rate") as Int,
            discount_percentage : try? unboxer.unbox(keyPath: "discount_percentage") as Int,
            category_breadcrumb : try? unboxer.unbox(keyPath: "category_breadcrumb") as String,
            shop_name : try? unboxer.unbox(keyPath: "shop_name") as String,
            category_id: try? unboxer.unbox(keyPath: "category_id") as String,
            shop_id : try? unboxer.unbox(keyPath: "shop_id") as Int,
            product_url : try? unboxer.unbox(keyPath: "product_url") as String,
            product_name :try? unboxer.unbox(keyPath: "product_name") as String,
            badges: try? unboxer.unbox(keyPath: "badges") as [ProductBadge],
            catalog_id : try? unboxer.unbox(keyPath: "catalog_id") as String,
            catalog_name  : try? unboxer.unbox(keyPath: "catalog_name") as String,
            catalog_price  : try? unboxer.unbox(keyPath: "catalog_price") as String,
            catalog_uri  : try? unboxer.unbox(keyPath: "catalog_uri") as String,
            catalog_image  : try? unboxer.unbox(keyPath: "catalog_image") as String,
            catalog_image_300  : try? unboxer.unbox(keyPath: "catalog_image_300") as String,
            catalog_description  : try? unboxer.unbox(keyPath: "catalog_description") as String,
            catalog_count_product  : try? unboxer.unbox(keyPath: "catalog_count_product") as String,
            labels: try? unboxer.unbox(keyPath:"labels") as [ProductLabel]
        )
    }
    
    internal func productFieldObjects() -> [String:String] {
        let productPrice = self.product_price?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return [
            "name"  : self.product_name!,
            "id"    : String(self.product_id),
            "price" : productPrice!,
            "brand" : self.shop_name!,
            "url"   : self.product_url!
        ]
    }
    
    internal func setTrackerInfo(info: NSDictionary) -> Void {
        trackerInfo = info
    }
    
    internal func productFieldObjectsForEnhancedEcommerceTracking() -> [AnyHashable:Any] {
        let productPrice = self.product_price?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let category = trackerInfo.object(forKey: "category") as? String ?? "none/other"
        let position = trackerInfo.object(forKey: "position") as? NSNumber ?? 1
        let attribution = trackerInfo.object(forKey: "attribution") as? String ?? "none/other"
        let page = (position.intValue / ProductAndWishlistNetworkManager.productPerPage) + 1
        
        return [
            "name"          : self.product_name ?? "",
            "id"            : String(self.product_id) ?? "",
            "price"         : Double(productPrice ?? "0"),
            "brand"         : "none/other",
            "url"           : self.product_url ?? "",
            "category"      : category,
            "variant"       : "none/other",
            "list"          : "/hot/\(trackerInfo.object(forKey: "key") ?? "") - product \(page)",
            "position"      : position,
            "dimension37"   : attribution
        ]
    }
}
