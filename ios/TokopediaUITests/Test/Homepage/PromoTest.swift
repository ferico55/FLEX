//
//  PromoTest.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class PromoTest: XCTestCase {
    
    var homepage = HomePage()
    var promo = PromoPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        homepage.goToPromoPage()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPromo() {
        promo.swipePromo()
        promo.clickPromo().isSuccess()
    }
    
    func testBuyPromo() {
        homepage.goToPromoPage()
        promo.clickPromo().buyProduct()
    }
}
