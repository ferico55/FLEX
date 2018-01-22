//
//  IntermediaryTest.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class IntermediaryTest: XCTestCase {
    
    var homepage = HomePage()
    var intermediary = Intermediary()
    var productDetail = ProductDetail()
    var hotlist = HotlistPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        homepage.goToCategory(category: "Fashion Wanita")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSwipeIntermediary() {
        intermediary.swipeIntermediary()
    }
    
    func testBanner() {
        intermediary.clickBanner()
    }
    
    func testSubcategory() {
        intermediary.clickSubcategory()
    }
    
    func testCuratedProduct() {
        intermediary.clickCuratedProduct()
        XCTAssert(productDetail.PDPView.exists)
    }
    
    func testHorizontalHotlist() {
        intermediary.clickHorizontalHotlist()
    }

    func testSquareHotlist() {
        intermediary.clickSquareHotlist()
    }
    
    func testVerticalHotlist() {
        intermediary.clickVerticalHotlist()
    }
    
    func testOfficialStore() {
        intermediary.clickIntermediaryOfficialStore()
    }
    
    func testExpandHideSubcategory() {
        intermediary.clickExpandSubcategory()
        intermediary.clickHideSubcategory()
    }
    
    func testVideo() {
        intermediary.clickVideo()
    }
    
    func testSeeAllCategoryResult() {
        intermediary.clickSeeAllCategory()
    }
    
    func testPromoInfo() {
        intermediary.clickPromotedInfo()
    }
    
    func testTutupTopAds() {
        intermediary.clickPromotedInfo()
        intermediary.clickTutupTopAds()
    }
}
