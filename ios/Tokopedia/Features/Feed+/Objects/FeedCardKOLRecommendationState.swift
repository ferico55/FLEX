//
//  FeedCardKOLRecommendationState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import ReSwift

struct FeedCardKOLRecommendationState: Render.StateType, ReSwift.StateType {
    var cardID = 0
    var users: [FeedCardKOLRecommendedUserState] = []
    var redirectURL = ""
    var title = ""
    var justFollowedUserID = 0
    var justFollowedUserIndex = -1
    
    init() {}
    
    init(content: FeedsQuery.Data.Feed.Datum.Content, page: Int, row: Int) {
        if let recommendation = content.kolrecommendation, let kols = recommendation.kols, kols.count > 0 {
            self.cardID = recommendation.index ?? 0
            self.title = recommendation.headerTitle ?? ""
            self.redirectURL = recommendation.exploreLink ?? ""
            
            self.users = kols.map { kol in
                if let recommendedUser = kol {
                    return FeedCardKOLRecommendedUserState(recommendedUser: recommendedUser, page: page, row: row)
                }
                
                return FeedCardKOLRecommendedUserState()
            }
        }
    }
}
