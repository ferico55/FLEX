//
//  UserTier.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UserTier : NSObject {
    let tierId: String
    let tierName: String
    let tierNameDescription: String
    let tierImageUrl: String
    let rewardPoints: String
    let rewardPointsString: String
    
    init(tierId: String, tierName: String, tierNameDescription: String, tierImageUrl: String, rewardPoints: String, rewardPointsString: String) {
        self.tierId = tierId
        self.tierName = tierName
        self.tierNameDescription = tierNameDescription
        self.tierImageUrl = tierImageUrl
        self.rewardPoints = rewardPoints
        self.rewardPointsString = rewardPointsString
    }
}

extension UserTier : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> UserTier {
        let json = JSON(source)
        
        let tierId = json["tier_id"].stringValue
        let tierName = json["tier_name"].stringValue
        let tierNameDescription = json["tier_name_desc"].stringValue
        let tierImageUrl = json["tier_image_url"].stringValue
        let rewardPoints = json["reward_points"].stringValue
        let rewardPointsString = json["reward_points_str"].stringValue
        
        return UserTier(tierId: tierId, tierName: tierName, tierNameDescription: tierNameDescription, tierImageUrl: tierImageUrl, rewardPoints: rewardPoints, rewardPointsString: rewardPointsString)
    }
}
