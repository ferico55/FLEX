//
//  WishlistPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class WishlistPage : Page, TokopediaTabBar {
    
    let wishlistCell = app.collectionViews["wishlistView"].children(matching: .cell).matching(identifier: "wishlistCell").element(boundBy: 0)
    
    func waitForPageLoaded(){
        waitFor(element: wishlistCell, status: .Exists)
    }
    
    func clickWishlistCell(product : String) {
        waitForPageLoaded()
        Page.app.staticTexts[product].tap()
    }
}
