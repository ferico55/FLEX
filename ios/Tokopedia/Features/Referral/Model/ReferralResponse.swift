//
//  ReferralResponse.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
internal class ReferralResponse: NSObject {
    internal var header = ReferralResponseHeader()
    internal var promoContent: ReferralPromoContent?
    override internal init(){}
    internal init(json:JSON) {
        if let header = json["header"].dictionary {
            self.header = ReferralResponseHeader(json: header)
        }
        if let promo_content = json["data"]["promo_content"].dictionary {
            self.promoContent = ReferralPromoContent(json: promo_content)
        }
    }
}
