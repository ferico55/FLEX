//
//  MyShopTest.swift
//  Tokopedia
//
//  Created by Alwan M on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class MyShopTest: XCTestCase {
    
    var more = MorePage()
    var login = LoginPage()
    var myshop = MyShopPage()
    
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
//        if login.isLogout() {
//            login.goLoginPage()
//            login.doLogin(email: "alwan.ubaidillah+101@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        }
//        if more.isBuyer() {
//            login.swithAccountSeller()
//        }
        more.goToMyShop()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//Tab Pengiriman
    func testTapPengirimanTab(){
        myshop.goToShopSetting()
        myshop.goToPengirimanTab()
        waitFor(element: myshop.provinceField, status: .Exists)
        XCTAssert(myshop.provinceField.exists)
    }
}
