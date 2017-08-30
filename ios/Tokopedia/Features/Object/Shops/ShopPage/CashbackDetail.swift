//
//  CashbackDetail.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(CashbackDetail)
final class CashbackDetail: NSObject, Unboxable {
    let cashbackStatus: Int!
    let cashbackPercent: Int!
    let isCashbackExpired: Bool!
    let cashbackValue: Int!
    
    init(cashbackStatus: Int, cashbackPercent: Int, isCashbackExpired: Bool, cashbackValue: Int) {
        self.cashbackStatus = cashbackStatus
        self.cashbackPercent = cashbackPercent
        self.isCashbackExpired = isCashbackExpired
        self.cashbackValue = cashbackValue
    }
    
    convenience init(unboxer: Unboxer) throws {
        self.init(
            cashbackStatus: try unboxer.unbox(keyPath: "cashback_status"),
            cashbackPercent: try unboxer.unbox(keyPath: "cashback_percent"),
            isCashbackExpired: (try unboxer.unbox(keyPath: "is_cashback_expired") as Int) == 1,
            cashbackValue: try unboxer.unbox(keyPath: "cashback_value")
        )
    }
}
