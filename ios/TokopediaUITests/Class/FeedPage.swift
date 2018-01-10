//
//  FeedPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class FeedPage : HomePage {

    let feedView = app.tables["feedView"]
    
    func swipeFeed() {
        waitFor(element: feedView, status: .Exists)
        feedView.swipeUp()
    }
}
