//
//  FeedCardKOLRecommendationState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render
import ReSwift
import UIKit

internal struct FeedCardKOLRecommendationState: Render.StateType, ReSwift.StateType {
    internal var cardID = 0
    internal var users: [FeedCardKOLRecommendedUserState] = []
    internal var redirectURL = ""
    internal var exploreText = ""
    internal var title = ""
    internal var justFollowedUserID = 0
    internal var justFollowedUserIndex = -1
    internal var page = 0
    internal var row = 0
    
    internal init() {}
    
    internal init(content: FeedsQuery.Data.Feed.Datum.Content, page: Int, row: Int) {
        if let recommendation = content.kolrecommendation, let kols = recommendation.kols, !(kols.isEmpty) {
            self.cardID = recommendation.index ?? 0
            self.title = recommendation.headerTitle ?? ""
            self.redirectURL = recommendation.exploreLink ?? ""
            self.exploreText = recommendation.exploreText ?? ""
            self.page = page
            self.row = row
            
            self.users = kols.map { kol in
                if let recommendedUser = kol {
                    return FeedCardKOLRecommendedUserState(recommendedUser: recommendedUser, page: page, row: row)
                }
                
                return FeedCardKOLRecommendedUserState()
            }
        }
    }
}
