//
//  NewOrderTest.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

class NewOrderTest: XCTestCase {
        
    var more = MorePage()
    var login = LoginPage()
    var sales = SalesPage()
    var newOrder = NewOrderPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+seller@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        if more.isBuyer() {
            login.swithAccountSeller()
        }
        more.goToSales()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAcceptOrder() {
        sales.goToNewOrder().acceptOrder()
    }
    
    func testCancelOrder() {
        sales.goToNewOrder().rejectOrderWith("Permintaan Pembeli", reason: "coba ya")
    }
    
}
