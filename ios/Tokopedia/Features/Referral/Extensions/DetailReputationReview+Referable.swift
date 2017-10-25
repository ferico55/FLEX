//
//  DetailReputationReview+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
extension DetailReputationReview: Referable {
    var desktopUrl: String {
        return NSString.tokopediaUrl() + "/" + self.product_uri
    }
    var deeplinkPath: String {
        return "product/" + self.product_id + "/review"
    }
    var feature: String {
        return "Review"
    }
    var title: String {
        return self.review_message
    }
    var buoDescription: String {
        return self.product_name
    }
    var utm_campaign: String {
        return "productReview"
    }
}
