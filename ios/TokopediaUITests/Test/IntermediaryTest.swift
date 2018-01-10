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
        intermediary.swipeBanner()
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
        intermediary.clickHorizontalHotlist()
        XCTAssert(hotlist.hotlistResultView.exists)
    }
    
    func testVerticalHotlist() {
        intermediary.clickVerticalHotlist()
        XCTAssert(hotlist.hotlistResultView.exists)
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
}
