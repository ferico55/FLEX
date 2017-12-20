//
//  GetCouponResponse.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class GetCouponResponse : NSObject {
    let totalData: Int
    let coupons: [Coupon]
    
    init(totalData: Int, coupons: [Coupon]) {
        self.totalData = totalData
        self.coupons = coupons
    }
}

extension GetCouponResponse : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> GetCouponResponse {
        let json = JSON(source)
        
        let totalData = json["header"]["total_data"].intValue
        let data = json["data"]
        
        let coupons = data["coupons"].arrayValue.map { couponJSON in
            Coupon.fromJSON(couponJSON.dictionaryValue)
        }
        
        return GetCouponResponse(totalData: totalData, coupons: coupons)
    }
}
