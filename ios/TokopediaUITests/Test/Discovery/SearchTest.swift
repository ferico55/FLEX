//
//  SearchTest.swift
//  Tokopedia
//
//  Created by nakama on 8/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class SearchTest: XCTestCase {
    
    var homepage = HomePage()
    var search = SearchPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearchProduct() {
        homepage.goToSearchPage().search("iPhone 7").clickProduct()
    }
}
