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
    
    let promoMainView = app.otherElements["promoMainView"]
    let promoView = app.otherElements.matching(identifier: "promoReactView").element(boundBy: 0) //first data promo
    
    func swipePromo() {
        waitFor(element: promoMainView, status: .Exists)
        promoMainView.swipeUp()
    }
    
    func clickPromo() -> PromoDetailPage {
        waitFor(element: promoView, status: .Exists)
        promoView.tap()
        return PromoDetailPage()
    }
}

class PromoDetailPage : PromoPage {
    
    let sharePromoButton = app.otherElements["sharePromoView"]
    let promoBuy = app.otherElements["promoBuyView"]

    func isSuccess() {
        XCTAssert(promoMainView.exists)
    }
    
    func sharePromo() {
        waitFor(element: sharePromoButton, status: .Exists)
        sharePromoButton.tap()
    }
    
    func buyProduct() {
        waitFor(element: promoBuy, status: .Exists)
        promoBuy.tap()
    }
}
