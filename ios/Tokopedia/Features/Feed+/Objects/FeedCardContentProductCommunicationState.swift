//
//  FeedCardContentProductCommunicationState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render
import ReSwift

struct FeedCardContentProductCommunicationState: Render.StateType, ReSwift.StateType {
    var imageURL = ""
    var title = ""
    var description = ""
    var buttonTitle = ""
    var redirectURL = ""
    var page = 0
    var row = 0

    init() {}
    
    init(data: FeedsQuery.Data.Feed.Datum.Content.KolCtum, page: Int, row: Int) {
        self.imageURL = data.imgHeader ?? ""
        self.title = data.title ?? ""
        self.description = data.subtitle ?? ""
        self.buttonTitle = data.buttonText ?? ""
        self.redirectURL = data.clickApplink ?? ""
        self.page = page
        self.row = row
    }
}
