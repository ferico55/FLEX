//
//  HotlistPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class HotlistPage : Page, TokopediaTabBar {
    
    let hotlistResultView = app.collectionViews["hotlistResultView"]
    let hotlistCell = app.otherElements.matching(identifier: "hotlistCell").element(boundBy: 0)
    
    func clickHotlist() -> Self {
        waitFor(element: hotlistCell, status: .Exists)
        hotlistCell.tap()
        return self
    }
}
