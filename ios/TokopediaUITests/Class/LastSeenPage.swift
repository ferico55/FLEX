//
//  LastSeenPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class LastSeenPage : HomePage {
    
    let lastSeenCell = app.collectionViews["lastSeen"].children(matching: .cell).matching(identifier: "productCell").element(boundBy: 0)
    
    func swipeLastSeen() {
        waitFor(element: lastSeenCell, status: .Exists)
        lastSeenCell.swipeUp()
    }
    
    func tapLastSeenCell() {
        waitFor(element: lastSeenCell, status: .Exists)
        lastSeenCell.tap()
        
    }
}
