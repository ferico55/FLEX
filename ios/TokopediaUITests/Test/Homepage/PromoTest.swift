//
//  PromoTest.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class PromoTest: XCTestCase {
    
    var homePage : HomePage = HomePage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPromo() {
        let promo = homePage.goToPromoPage().clickPromo()
        waitFor(element: promo.promoDetailView, status: .Exists)
        XCTAssert(promo.promoDetailView.exists)
        
    }
    
    func testBuyPromo() {
        let promo = homePage.goToPromoPage().clickPromo()
        promo.buyProduct()
    }
}
