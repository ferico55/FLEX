//
//  WishlistTest.swift
//  Tokopedia
//
//  Created by nakama on 8/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class WishlistTest: XCTestCase {
    
    var homePage : HomePage = HomePage()
    var wishlist = WishlistPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if !homePage.isUserLogin() {
            LoginTest().testLoginBuyer()
            homePage.homeTab.tap()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWishlist() {
        homePage.goWishlistPage()
        let openWishlist = wishlist.clickWishlistCell()
        XCTAssert(openWishlist.PDPView.exists)
    }
    
    func testWishlistSearch(){
        homePage.goWishlistPage()
        wishlist.searchWishlist("wishlist")
        waitFor(element: wishlist.resultCountLabel, status: .Exists)
        XCTAssert(wishlist.resultCountLabel.exists)
    }

    func testResetWishlistSearch(){
        homePage.goWishlistPage()
        wishlist.searchWishlist("wishlist")
        wishlist.resetWishlistSearch.tap()
        XCTAssertTrue(wishlist.wishlistSearchTextField.placeholderValue as? String == "Cari wishlist kamu")
    }

    func testSeeAllWishlist(){
        homePage.goWishlistPage()
        wishlist.searchWishlist("wishlist")
        wishlist.seeAllWishlist.tap()
        XCTAssertTrue(wishlist.wishlistSearchTextField.placeholderValue as? String == "Cari wishlist kamu")
    }

    func testRemoveWishlist(){
        homePage.goWishlistPage()
        if wishlist.wishlistCount > 0 {
            wishlist.removeWishlist("yes")
        }
        else
        {
            
        }
    }

    func testCancelRemoveWishlist(){
        homePage.goWishlistPage()
        if wishlist.wishlistCount > 0 {
            wishlist.removeWishlist("no")
        }
        else
        {
            
        }
    }

}

