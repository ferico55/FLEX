//
//  HotlistTest.swift
//  Tokopedia
//
//  Created by nakama on 8/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class HotlistTest: XCTestCase {
    
    var hotlist = HotlistPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        hotlist.goHotlistPage()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHotlist() {
        hotlist.clickHotlist()
        XCTAssert(hotlist.hotlistResultView.exists)
    }
}
