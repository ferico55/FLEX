//
//  ProductUnbox.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import FirebaseRemoteConfig
import Foundation
import SwiftyJSON
import Unbox

internal struct ProductUnbox {
    internal var id: String
    internal var name: String
    internal let key: String
    internal var url: String
    internal var info: ProductInfo
    internal let shop: ProductShop
    internal var images: [ProductImage]
    internal var fullImages: [ProductImage]
    internal let categories: [ProductCategory]
    internal let rating: ProductRating
    internal let isOwner: Bool
    internal var isWishlisted: Bool
    internal var isShopFavorited: Bool
    internal let isFreeReturned: Int
    internal let cashback: String
    internal let soldCount: String
    internal let successRate: String
    internal let viewCount: String
    internal let reviewCount: String
    internal let talkCount: String
    internal let lastUpdated: String
    internal let wholesale: [ProductWholesale]
    internal let preorderDetail: ProductPreorderDetail
    internal var shipments: [ProductShipment]
    internal var installments: [ProductInstallment]
    internal var videos: [ProductVideo]
    internal var otherProducts: [OtherProduct]
    internal var campaign: ShopProductCampaign?
    internal var mostHelpfulReviews: [ProductReview]
    internal var latestDiscussion: ProductTalk?
    internal var variantProduct: ProductVariant?
}

extension ProductUnbox: Unboxable {

    internal init(unboxer: Unboxer) throws {
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
        self.campaign = try? unboxer.unbox(keyPath: "data.campaign")

        self.fullImages = images

        if let campaign = self.campaign, campaign.isActive {
            self.info.price = campaign.discountedPriceFormat
        } else {
            self.campaign = nil
        }

        self.mostHelpfulReviews = [ProductReview]()
        self.latestDiscussion = nil
    }

    internal func lastLevelCategory() -> ProductCategory {
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

internal struct ProductInfo {
    internal var price: String
    internal let priceUnformatted: Int
    internal let description: String
    internal let minimumOrder: String
    internal let weight: String
    internal let condition: String
    internal let insurance: String
    internal let returnable: String
    internal let returnInfo: ReturnInfo
    internal var etalaseName: String
    internal var etalaseId: String
    internal var catalogName: String
    internal var catalogId: String
    internal var status: ProductInfoStatus
    internal let statusTitle: String
    internal let statusMessage: String
    internal let hasVariant: Bool
}

extension ProductInfo: Unboxable {
    internal init(unboxer: Unboxer) throws {
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

        let remoteConfigEnableVariant = RemoteConfig.remoteConfig().configValue(forKey: "iosapp_discovery_enable_pdp_variant").boolValue
        if remoteConfigEnableVariant {
            self.hasVariant = try unboxer.unbox(keyPath: "has_variant")
        } else {
            self.hasVariant = false
        }
    }

    internal func descriptionHtml() -> String {
        return NSString.convertHTML(self.description)
    }
}

public enum ProductShopStatus: Int, UnboxableEnum {
    case open = 1
    case closed = 2
    case moderated = 3
    case inactive = 4
}

internal struct ProductShop {
    internal let id: String
    internal let name: String
    internal let location: String
    internal let avatarURL: String
    internal let isGoldMerchant: Bool
    internal let isOfficial: Bool
    internal let lastLogin: String
    internal var badgeImage: UIImage
    internal let badgeLevel: String
    internal let badgeSet: String
    internal let domain: String
    internal let reputationScore: String
    internal let closeUntil: String
    internal let status: ProductShopStatus
}

extension ProductShop: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "shop_id")
        self.name = try unboxer.unbox(keyPath: "shop_name")
        self.location = try unboxer.unbox(keyPath: "shop_location")
        self.avatarURL = try unboxer.unbox(keyPath: "shop_avatar")
        self.isGoldMerchant = try unboxer.unbox(keyPath: "shop_is_gold") == 1
        self.isOfficial = try unboxer.unbox(keyPath: "shop_is_official") == "1"
        self.lastLogin = try unboxer.unbox(keyPath: "shop_owner_last_login")
        self.badgeLevel = try unboxer.unbox(keyPath: "shop_stats.shop_badge_level.level")
        self.badgeSet = try unboxer.unbox(keyPath: "shop_stats.shop_badge_level.set")
        self.badgeImage = (isOfficial ? #imageLiteral(resourceName: "badge_official_small.png") : (isGoldMerchant ? #imageLiteral(resourceName: "Badges_gold_merchant") : UIImage()))
        self.domain = try unboxer.unbox(keyPath: "shop_domain")
        self.reputationScore = try unboxer.unbox(keyPath: "shop_stats.shop_reputation_score")
        self.closeUntil = try unboxer.unbox(keyPath: "shop_is_closed_until")
        self.status = try unboxer.unbox(keyPath: "shop_status")
    }
}

internal struct ProductImage {
    internal var normalURL: String
    internal let imageDescription: String

    internal init(normalURL: String, imageDescription: String = "") {
        self.normalURL = normalURL
        self.imageDescription = imageDescription
    }
}

extension ProductImage: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.normalURL = try unboxer.unbox(keyPath: "image_src")
        self.imageDescription = try unboxer.unbox(keyPath: "image_description")
    }
}

internal struct ProductCategory {
    internal let id: String
    internal let name: String
}

extension ProductCategory: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "department_id")
        self.name = try unboxer.unbox(keyPath: "department_name")
    }
}

internal struct ProductRating {
    internal let qualityRate: String
    internal let qualityStarRate: String
    internal let accuracyRate: String
    internal let accuracyStarRate: String
}

extension ProductRating: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.qualityRate = try unboxer.unbox(keyPath: "product_rating_point")
        self.qualityStarRate = try unboxer.unbox(keyPath: "product_rating_star_point")
        self.accuracyRate = try unboxer.unbox(keyPath: "product_rate_accuracy_point")
        self.accuracyStarRate = try unboxer.unbox(keyPath: "product_accuracy_star_rate")
    }
}

internal struct ReturnInfo {
    internal let iconImage: String
    internal let colorString: String
    internal let info: String
}

extension ReturnInfo: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.iconImage = try unboxer.unbox(keyPath: "icon")
        self.colorString = try unboxer.unbox(keyPath: "color_hex")
        self.info = try unboxer.unbox(keyPath: "content")
    }

    internal func colorRGB() -> UIColor {
        return UIColor.fromHexString(self.colorString)
    }
}

internal struct ProductPreorderDetail {
    internal let isPreorder: Bool
    internal let preorderTime: String
    internal let preorderTimeType: String
}

extension ProductPreorderDetail: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.isPreorder = try unboxer.unbox(keyPath: "preorder_status")
        self.preorderTime = try unboxer.unbox(keyPath: "preorder_process_time")
        self.preorderTimeType = try unboxer.unbox(keyPath: "preorder_process_time_type_string")
    }
}

internal struct ProductVideos {
    internal let videos: [ProductVideo]
}

extension ProductVideos: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.videos = try unboxer.unbox(keyPath: "data.0.video")
    }
}

internal struct ProductVideo {
    internal let url: String
    internal let type: String
    internal let status: Bool
}

extension ProductVideo: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.url = try unboxer.unbox(key: "url")
        self.type = try unboxer.unbox(key: "type")
        self.status = try unboxer.unbox(key: "status")
    }
}

internal struct OtherProducts {
    internal let products: [OtherProduct]
}

extension OtherProducts: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.products = try unboxer.unbox(keyPath: "data.products")
    }
}

internal struct OtherProduct {
    internal let id: String
    internal let name: String
    internal let image: String
    internal let price: String
}

extension OtherProduct: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "product_id")
        self.name = try unboxer.unbox(key: "product_name")
        self.image = try unboxer.unbox(key: "product_image")
        self.price = try unboxer.unbox(key: "product_price")
    }
}

internal struct ProductShipment {
    internal let id: String
    internal let name: String
    internal let logo: String
    internal let packages: [String]
}

extension ProductShipment: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "shipping_id")
        self.name = try unboxer.unbox(key: "shipping_name")
        self.logo = try unboxer.unbox(key: "logo")
        self.packages = (try? unboxer.unbox(key: "package_names")) ?? []
    }
}

internal struct ProductWholesale {
    internal let minQuantity: String
    internal let maxQuantity: String
    internal let price: String
}

extension ProductWholesale: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.minQuantity = try unboxer.unbox(key: "wholesale_min")
        self.maxQuantity = try unboxer.unbox(key: "wholesale_max")
        self.price = try unboxer.unbox(key: "wholesale_price")
    }
}

internal struct ProductInstallment {
    internal let id: String
    internal let name: String
    internal let icon: String
    internal let terms: [String : ProductInstallmentTerm]
}

extension ProductInstallment: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.icon = try unboxer.unbox(key: "icon")
        self.terms = try unboxer.unbox(key: "terms")
    }
}

internal struct ProductInstallmentTerm {
    internal let minimumPurchase: String
    internal let installmentPrice: String
    internal let percentage: String
}

extension ProductInstallmentTerm: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.minimumPurchase = try unboxer.unbox(key: "min_purchase")
        self.installmentPrice = try unboxer.unbox(key: "installment_price")
        self.percentage = try unboxer.unbox(key: "percentage")
    }
}

internal struct ProductReviews {
    internal let reviews: [ProductReview]
}

extension ProductReviews: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.reviews = try unboxer.unbox(keyPath: "data.list")
    }
}

internal struct ProductReview {
    internal let reputationID: String
    internal let reviewID: String
    internal let rating: Int
    internal let message: String
    internal let publishTime: String
    internal let reviewerID: String
    internal let reviewerName: String
    internal let reviewerImage: String
}

extension ProductReview: Unboxable {
    internal init(unboxer: Unboxer) throws {
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

internal struct ProductTalks {
    internal let talks: [ProductTalk]
}

extension ProductTalks: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.talks = try unboxer.unbox(keyPath: "data.list")
    }
}

internal struct ProductTalk {
    internal let talkID: String
    internal let userName: String
    internal let userImage: String
    internal let message: String
    internal let publishTime: String
    internal let userLabel: String
    internal var comments: [ProductTalkComment]
}

extension ProductTalk: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.talkID = try unboxer.unbox(key: "talk_id")
        self.userName = try unboxer.unbox(key: "talk_user_name")
        self.userImage = try unboxer.unbox(key: "talk_user_image")
        self.message = try unboxer.unbox(key: "talk_message")
        self.publishTime = try unboxer.unbox(keyPath: "talk_create_time_list.date_time_ios")
        self.userLabel = try unboxer.unbox(key: "talk_user_label")
        self.comments = [ProductTalkComment]()
    }
}

internal struct ProductTalkComments {
    internal let comments: [ProductTalkComment]
}

extension ProductTalkComments: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.comments = try unboxer.unbox(keyPath: "data.list")
    }
}

internal struct ProductTalkComment {
    internal let commentID: String
    internal let userName: String
    internal let userImage: String
    internal let message: String
    internal let publishTime: String
    internal let isSeller: Bool
    internal let userLabel: String
    internal let shopName: String
}

extension ProductTalkComment: Unboxable {
    internal init(unboxer: Unboxer) throws {
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

internal struct ShopProductCampaign {
    internal let originalPrice: String
    internal let originalPriceFormat: String
    internal let discountedPrice: String
    internal let startDate: String
    internal let endDate: String
    internal let discountedPercentage: Int
    internal let discountedPriceFormat: String
    internal let isActive: Bool

    internal init(originalPrice: String, originalPriceFormat: String, discountedPrice: String, startDate: String, endDate: String, discountedPercentage: Int, discountedPriceFormat: String, isActive: Bool) {
        self.originalPrice = originalPrice
        self.originalPriceFormat = originalPriceFormat
        self.discountedPrice = discountedPrice
        self.startDate = startDate
        self.endDate = endDate
        self.discountedPercentage = discountedPercentage
        self.discountedPriceFormat = discountedPriceFormat
        self.isActive = isActive
    }
}

extension ShopProductCampaign: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.init(originalPrice: try unboxer.unbox(key: "original_price"),
                  originalPriceFormat: try unboxer.unbox(key: "original_price_fmt"),
                  discountedPrice: try unboxer.unbox(key: "discounted_price"),
                  startDate: try unboxer.unbox(key: "start_date"),
                  endDate: try unboxer.unbox(key: "end_date"),
                  discountedPercentage: try unboxer.unbox(key: "discounted_percentage"),
                  discountedPriceFormat: try unboxer.unbox(key: "discounted_price_fmt"),
                  isActive: try unboxer.unbox(key: "is_active"))
    }

    internal init(json: JSON) {
        let originalPrice = json["original_price"].stringValue
        let originalPriceFormat = json["original_price_fmt"].stringValue
        let discountedPrice = json["discounted_price"].stringValue
        let startDate = json["start_date"].stringValue
        let endDate = json["end_date"].stringValue
        let discountedPercentage = json["discounted_percentage"].intValue
        let discountedPriceFormat = json["discounted_price_fmt"].stringValue
        let isActive = json["is_active"].boolValue

        self.init(originalPrice: originalPrice,
                  originalPriceFormat: originalPriceFormat,
                  discountedPrice: discountedPrice,
                  startDate: startDate,
                  endDate: endDate,
                  discountedPercentage: discountedPercentage,
                  discountedPriceFormat: discountedPriceFormat,
                  isActive: isActive)
    }

    internal init(formatted json: JSON) {
        let originalPrice = json["originalPrice"].stringValue
        let originalPriceFormat = json["originalPriceFormat"].stringValue
        let discountedPrice = json["discountedPrice"].stringValue
        let startDate = json["startDate"].stringValue
        let endDate = json["endDate"].stringValue
        let discountedPercentage = json["discountedPercentage"].intValue
        let discountedPriceFormat = json["discountedPriceFormat"].stringValue
        let isActive = json["isActive"].boolValue

        self.init(originalPrice: originalPrice,
                  originalPriceFormat: originalPriceFormat,
                  discountedPrice: discountedPrice,
                  startDate: startDate,
                  endDate: endDate,
                  discountedPercentage: discountedPercentage,
                  discountedPriceFormat: discountedPriceFormat,
                  isActive: isActive)
    }

    internal var dictionary: [String : Any] {
        return [
            "originalPrice": self.originalPrice,
            "originalPriceFormat": self.originalPriceFormat,
            "discountedPrice": self.discountedPrice,
            "startDate": self.startDate,
            "endDate": self.endDate,
            "discountedPercentage": self.discountedPercentage,
            "discountedPriceFormat": self.discountedPriceFormat,
            "isActive": self.isActive
        ]
    }
}
