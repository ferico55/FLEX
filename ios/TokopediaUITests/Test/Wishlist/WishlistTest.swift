//
//  WishlistTest.swift
//  Tokopedia
//
//  Created by nakama on 8/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class WishlistTest: XCTestCase {
    
    var login = LoginPage()
    var wishlist = WishlistPage()
    var productDetail = ProductDetail()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        wishlist.goWishlistPage()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWishlist() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            wishlist.goWishlistPage()
        }
        wishlist.clickWishlistCell(product: "Do More")
        XCTAssert(productDetail.PDPView.exists)
    }
}
