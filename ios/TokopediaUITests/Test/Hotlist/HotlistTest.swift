//
//  HotlistTest.swift
//  Tokopedia
//
//  Created by nakama on 8/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class HotlistTest: XCTestCase {
    
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
    
    func testHotlist() {
        let hotlist = homePage.goHotlistPage().clickHotlist()
        waitFor(element: hotlist.hotlistResultView, status: .Exists)
        XCTAssert(hotlist.hotlistResultView.exists)
    }
}
