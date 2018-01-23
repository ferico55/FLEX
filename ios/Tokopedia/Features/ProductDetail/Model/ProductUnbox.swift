//
//  ProductUnbox.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox
import Foundation

struct ProductUnbox {
    let id: String
    let name: String
    let key: String
    let url: String
    var info: ProductInfo
    let shop: ProductShop
    let images: [ProductImage]
    let categories: [ProductCategory]
    let rating: ProductRating
    let isOwner: Bool
    var isWishlisted: Bool
    var isShopFavorited: Bool
    let isFreeReturned: Int
    let cashback: String
    let soldCount: String
    let successRate: String
    let viewCount: String
    let reviewCount: String
    let talkCount: String
    let lastUpdated: String
    let wholesale: [ProductWholesale]
    let preorderDetail: ProductPreorderDetail
    var shipments: [ProductShipment]
    var installments: [ProductInstallment]
    var videos: [ProductVideo]
    var otherProducts: [OtherProduct]
    var campaign: ShopProductPageCampaignInfo?
    var mostHelpfulReviews: [ProductReview]
    var latestDiscussion: ProductTalk?
}

extension ProductUnbox: Unboxable {

    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "data.info.product_id")
        self.name = try unboxer.unbox(keyPath: "data.info.product_name")
        self.key = try unboxer.unbox(keyPath: "data.info.product_key")
        self.url = try unboxer.unbox(keyPath: "data.info.product_url")
        self.info = try unboxer.unbox(keyPath: "data.info")
        self.shop = try unboxer.unbox(keyPath: "data.shop_info")
        self.images = try unboxer.unbox(keyPath: "data.product_images") as [ProductImage]
        self.categories = try unboxer.unbox(keyPath: "data.breadcrumb")
        self.rating = try unboxer.unbox(keyPath: "data.rating")
        self.isOwner = try unboxer.unbox(keyPath: "data.shop_info.shop_is_owner")
        self.isWishlisted = try unboxer.unbox(keyPath: "data.info.product_already_wishlist")
        self.isShopFavorited = try unboxer.unbox(keyPath: "data.shop_info.shop_already_favorited")
        self.isFreeReturned = try unboxer.unbox(keyPath: "data.shop_info.shop_is_free_returns")
        self.cashback = try unboxer.unbox(keyPath: "data.cashback.product_cashback")
        self.soldCount = try unboxer.unbox(keyPath: "data.statistic.product_sold_count")
        self.successRate = try unboxer.unbox(keyPath: "data.statistic.product_success_rate")
        self.viewCount = try unboxer.unbox(keyPath: "data.statistic.product_view_count")
        self.reviewCount = try unboxer.unbox(keyPath: "data.statistic.product_review_count")
        self.talkCount = try unboxer.unbox(keyPath: "data.statistic.product_talk_count")
        self.lastUpdated = try unboxer.unbox(keyPath: "data.info.product_last_update")
        self.wholesale = try unboxer.unbox(keyPath: "data.wholesale_price")
        self.preorderDetail = try unboxer.unbox(keyPath: "data.preorder")
        self.shipments = try unboxer.unbox(keyPath: "data.shop_info.shop_shipments")
        self.installments = try unboxer.unbox(keyPath: "data.info.product_installments")
        self.videos = [ProductVideo]()
        self.otherProducts = [OtherProduct]()
        self.campaign = nil
        self.mostHelpfulReviews = [ProductReview]()
        self.latestDiscussion = nil
    }

    func lastLevelCategory() -> ProductCategory {
        guard let category = self.categories.last else { return ProductCategory(id: "0", name: "") }

        return category
    }
}

public enum ProductInfoStatus: String, UnboxableEnum {
    case deleted = "0"
    case active = "1"
    case best = "2"
    case warehouse = "3"
    case pending = "-1"
    case banned = "-2"
}

struct ProductInfo {
    let price: String
    let priceUnformatted: Int
    let description: String
    let minimumOrder: String
    let weight: String
    let condition: String
    let insurance: String
    let returnable: String
    let returnInfo: ReturnInfo
    var etalaseName: String
    var etalaseId: String
    var catalogName: String
    var catalogId: String
    var status: ProductInfoStatus
    let statusTitle: String
    let statusMessage: String
}

extension ProductInfo: Unboxable {
    init(unboxer: Unboxer) throws {
        self.price = try unboxer.unbox(keyPath: "product_price")
        self.priceUnformatted = try unboxer.unbox(keyPath: "product_price_unfmt")
        self.description = try unboxer.unbox(keyPath: "product_description")
        self.minimumOrder = try unboxer.unbox(keyPath: "product_min_order")
        self.weight = try unboxer.unbox(keyPath: "product_weight") + " " + unboxer.unbox(keyPath: "product_weight_unit") as String
        self.condition = try unboxer.unbox(keyPath: "product_condition")
        self.insurance = try unboxer.unbox(keyPath: "product_insurance")
        self.returnable = try unboxer.unbox(keyPath: "product_returnable")
        self.returnInfo = try unboxer.unbox(keyPath: "return_info")
        self.etalaseName = try unboxer.unbox(keyPath: "product_etalase")
        self.etalaseId = try unboxer.unbox(keyPath: "product_etalase_id")
        self.catalogName = try unboxer.unbox(keyPath: "catalog_name")
        self.catalogId = try unboxer.unbox(keyPath: "catalog_id")
        self.status = try unboxer.unbox(keyPath: "product_status")
        self.statusTitle = try unboxer.unbox(keyPath: "product_status_title")
        self.statusMessage = try unboxer.unbox(keyPath: "product_status_message")
    }

    func descriptionHtml() -> String {
        return NSString.convertHTML(self.description)
    }
}

public enum ProductShopStatus: Int, UnboxableEnum {
    case open = 1
    case closed = 2
    case moderated = 3
    case inactive = 4
}

struct ProductShop {
    let id: String
    let name: String
    let location: String
    let avatarURL: String
    let isGoldMerchant: Bool
    let isOfficial: Bool
    let lastLogin: String
    var badgeImage: UIImage
    let badgeLevel: String
    let badgeSet: String
    let domain: String
    let reputationScore: String
    let closeUntil: String
    let status: ProductShopStatus
}

extension ProductShop: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "shop_id")
        self.name = try unboxer.unbox(keyPath: "shop_name")
        self.location = try unboxer.unbox(keyPath: "shop_location")
        self.avatarURL = try unboxer.unbox(keyPath: "shop_avatar")
        self.isGoldMerchant = try unboxer.unbox(keyPath: "shop_is_gold") == 1
        self.isOfficial = try unboxer.unbox(keyPath: "shop_is_official") == "1"
        self.lastLogin = try unboxer.unbox(keyPath: "shop_owner_last_login")
        self.badgeLevel = try unboxer.unbox(keyPath: "shop_stats.shop_badge_level.level")
        self.badgeSet = try unboxer.unbox(keyPath: "shop_stats.shop_badge_level.set")
        self.badgeImage = (isOfficial ? UIImage(named: "badge_official_small") : (isGoldMerchant ? UIImage(named: "Badges_gold_merchant") : UIImage()))!
        self.domain = try unboxer.unbox(keyPath: "shop_domain")
        self.reputationScore = try unboxer.unbox(keyPath: "shop_stats.shop_reputation_score")
        self.closeUntil = try unboxer.unbox(keyPath: "shop_is_closed_until")
        self.status = try unboxer.unbox(keyPath: "shop_status")
    }
}

struct ProductImage {
    let normalURL: String
    let imageDescription: String

}

extension ProductImage: Unboxable {
    init(unboxer: Unboxer) throws {
        self.normalURL = try unboxer.unbox(keyPath: "image_src")
        self.imageDescription = try unboxer.unbox(keyPath: "image_description")
    }
}

struct ProductCategory {
    let id: String
    let name: String
}

extension ProductCategory: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "department_id")
        self.name = try unboxer.unbox(keyPath: "department_name")
    }
}

struct ProductRating {
    let qualityRate: String
    let qualityStarRate: String
    let accuracyRate: String
    let accuracyStarRate: String
}

extension ProductRating: Unboxable {
    init(unboxer: Unboxer) throws {
        self.qualityRate = try unboxer.unbox(keyPath: "product_rating_point")
        self.qualityStarRate = try unboxer.unbox(keyPath: "product_rating_star_point")
        self.accuracyRate = try unboxer.unbox(keyPath: "product_rate_accuracy_point")
        self.accuracyStarRate = try unboxer.unbox(keyPath: "product_accuracy_star_rate")
    }
}

struct ReturnInfo {
    let iconImage: String
    let colorString: String
    let info: String
}

extension ReturnInfo: Unboxable {
    init(unboxer: Unboxer) throws {
        self.iconImage = try unboxer.unbox(keyPath: "icon")
        self.colorString = try unboxer.unbox(keyPath: "color_hex")
        self.info = try unboxer.unbox(keyPath: "content")
    }

    func colorRGB() -> UIColor {
        return UIColor.fromHexString(self.colorString)
    }
}

struct ProductPreorderDetail {
    let isPreorder: Bool
    let preorderTime: String
    let preorderTimeType: String
}

extension ProductPreorderDetail: Unboxable {
    init(unboxer: Unboxer) throws {
        self.isPreorder = try unboxer.unbox(keyPath: "preorder_status")
        self.preorderTime = try unboxer.unbox(keyPath: "preorder_process_time")
        self.preorderTimeType = try unboxer.unbox(keyPath: "preorder_process_time_type_string")
    }
}

struct ProductVideos {
    let videos: [ProductVideo]
}

extension ProductVideos: Unboxable {
    init(unboxer: Unboxer) throws {
        self.videos = try unboxer.unbox(keyPath: "data.0.video")
    }
}

struct ProductVideo {
    let url: String
    let type: String
    let status: Bool
}

extension ProductVideo: Unboxable {
    init(unboxer: Unboxer) throws {
        self.url = try unboxer.unbox(key: "url")
        self.type = try unboxer.unbox(key: "type")
        self.status = try unboxer.unbox(key: "status")
    }
}

struct OtherProducts {
    let products: [OtherProduct]
}

extension OtherProducts: Unboxable {
    init(unboxer: Unboxer) throws {
        self.products = try unboxer.unbox(keyPath: "data.products")
    }
}

struct OtherProduct {
    let id: String
    let name: String
    let image: String
    let price: String
}

extension OtherProduct: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "product_id")
        self.name = try unboxer.unbox(key: "product_name")
        self.image = try unboxer.unbox(key: "product_image")
        self.price = try unboxer.unbox(key: "product_price")
    }
}

struct ProductShipment {
    let id: String
    let name: String
    let logo: String
    let packages: [String]
}

extension ProductShipment: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "shipping_id")
        self.name = try unboxer.unbox(key: "shipping_name")
        self.logo = try unboxer.unbox(key: "logo")
        self.packages = (try? unboxer.unbox(key: "package_names")) ?? []
    }
}

struct ProductWholesale {
    let minQuantity: String
    let maxQuantity: String
    let price: String
}

extension ProductWholesale: Unboxable {
    init(unboxer: Unboxer) throws {
        self.minQuantity = try unboxer.unbox(key: "wholesale_min")
        self.maxQuantity = try unboxer.unbox(key: "wholesale_max")
        self.price = try unboxer.unbox(key: "wholesale_price")
    }
}

struct ProductInstallment {
    let id: String
    let name: String
    let icon: String
    let terms: [String : ProductInstallmentTerm]
}

extension ProductInstallment: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.icon = try unboxer.unbox(key: "icon")
        self.terms = try unboxer.unbox(key: "terms")
    }
}

struct ProductInstallmentTerm {
    let minimumPurchase: String
    let installmentPrice: String
    let percentage: String
}

extension ProductInstallmentTerm: Unboxable {
    init(unboxer: Unboxer) throws {
        self.minimumPurchase = try unboxer.unbox(key: "min_purchase")
        self.installmentPrice = try unboxer.unbox(key: "installment_price")
        self.percentage = try unboxer.unbox(key: "percentage")
    }
}

struct ProductReviews {
    let reviews: [ProductReview]
}

extension ProductReviews: Unboxable {
    init(unboxer: Unboxer) throws {
        self.reviews = try unboxer.unbox(keyPath: "data.list")
    }
}

struct ProductReview {
    let reputationID: String
    let reviewID: String
    let rating: Int
    let message: String
    let publishTime: String
    let reviewerID: String
    let reviewerName: String
    let reviewerImage: String
}

extension ProductReview: Unboxable {
    init(unboxer: Unboxer) throws {
        self.reputationID = try unboxer.unbox(key: "reputation_id")
        self.reviewID = try unboxer.unbox(key: "review_id")
        self.rating = try unboxer.unbox(key: "product_rating")
        self.message = try unboxer.unbox(key: "review_message")
        self.publishTime = try unboxer.unbox(keyPath: "review_create_time.date_time_fmt1")
        self.reviewerID = try unboxer.unbox(keyPath: "user.user_id")
        self.reviewerName = try unboxer.unbox(keyPath: "user.full_name")
        self.reviewerImage = try unboxer.unbox(keyPath: "user.user_image")
    }
}

struct ProductTalks {
    let talks: [ProductTalk]
}

extension ProductTalks: Unboxable {
    init(unboxer: Unboxer) throws {
        self.talks = try unboxer.unbox(keyPath: "data.list")
    }
}

struct ProductTalk {
    let talkID: String
    let userName: String
    let userImage: String
    let message: String
    let publishTime: String
    let userLabel: String
    var comments: [ProductTalkComment]
}

extension ProductTalk: Unboxable {
    init(unboxer: Unboxer) throws {
        self.talkID = try unboxer.unbox(key: "talk_id")
        self.userName = try unboxer.unbox(key: "talk_user_name")
        self.userImage = try unboxer.unbox(key: "talk_user_image")
        self.message = try unboxer.unbox(key: "talk_message")
        self.publishTime = try unboxer.unbox(keyPath: "talk_create_time_list.date_time_ios")
        self.userLabel = try unboxer.unbox(key: "talk_user_label")
        self.comments = [ProductTalkComment]()
    }
}

struct ProductTalkComments {
    let comments: [ProductTalkComment]
}

extension ProductTalkComments: Unboxable {
    init(unboxer: Unboxer) throws {
        self.comments = try unboxer.unbox(keyPath: "data.list")
    }
}

struct ProductTalkComment {
    let commentID: String
    let userName: String
    let userImage: String
    let message: String
    let publishTime: String
    let isSeller: Bool
    let userLabel: String
    let shopName: String
}

extension ProductTalkComment: Unboxable {
    init(unboxer: Unboxer) throws {
        self.commentID = try unboxer.unbox(key: "comment_id")
        self.userName = try unboxer.unbox(key: "comment_user_name")
        self.userImage = try unboxer.unbox(key: "comment_user_image")
        self.message = try unboxer.unbox(key: "comment_message")
        self.publishTime = try unboxer.unbox(keyPath: "comment_create_time_list.date_time_ios")
        self.isSeller = try unboxer.unbox(key: "comment_is_seller")
        self.userLabel = try unboxer.unbox(key: "comment_user_label")
        self.shopName = try unboxer.unbox(key: "comment_shop_name")
    }
}

