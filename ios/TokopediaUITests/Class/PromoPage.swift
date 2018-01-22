//
//  PromoPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 18/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class PromoPage : HomePage {
    
    let promoCell = app.otherElements.matching(identifier: "promoCell").element(boundBy: 0)
    
    func clickPromo() -> PromoDetailPage {
        waitFor(element: promoCell, status: .Exists)
        promoCell.tap()
        return PromoDetailPage()
    }
}

class PromoDetailPage : PromoPage {
    
    let promoDetailView = Page.app.navigationBars["PromoDetail"]
    let sharePromoButton = app.otherElements["sharePromoView"]
    let promoBuy = app.otherElements["promoBuyView"]
    
    func sharePromo() {
        waitFor(element: sharePromoButton, status: .Exists)
        sharePromoButton.tap()
    }
    
    func buyProduct() {
        if waitFor(element: promoBuy, status: .Exists) ==  .timedOut{
            
        }
        else{
           promoBuy.tap()
           XCTAssert(!promoDetailView.exists)
        }
        
    }
}
