//
//  Coupon.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Coupon : NSObject {
    let id: Int64
    let promoId: Int64
    let code: String
    let title: String
    let subTitle: String
    let couponDescription: String
    let expired: String
    let icon: String
    let imageUrl: String
    let imageUrlMobile: String
    
    var errorMessage: String = ""
    
    init(
        id: Int64,
        promoId: Int64,
        code: String,
        title: String,
        subTitle: String,
        couponDescription: String,
        expired: String,
        icon: String,
        imageUrl: String,
        imageUrlMobile: String
    ) {
        self.id = id
        self.promoId = promoId
        self.code = code
        self.title = title
        self.subTitle = subTitle
        self.couponDescription = couponDescription
        self.icon = icon
        self.expired = expired
        self.imageUrl = imageUrl
        self.imageUrlMobile = imageUrlMobile
    }
}

extension Coupon : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> Coupon {
        let json = JSON(source)
        
        let id = json["id"].int64Value
        let promoId = json["promo_id"].int64Value
        let code = json["code"].stringValue
        let title = json["title"].stringValue
        let subTitle = json["sub_title"].stringValue
        let couponDescription = json["description"].stringValue
        let expired = json["expired"].stringValue
        let icon = json["icon"].stringValue
        let imageUrl = json["image_url"].stringValue
        let imageUrlMobile = json["image_url_mobile"].stringValue
        
        return Coupon(id: id, promoId: promoId, code: code, title: title, subTitle: subTitle, couponDescription: couponDescription, expired: expired, icon: icon, imageUrl: imageUrl, imageUrlMobile: imageUrlMobile)
    }
}
