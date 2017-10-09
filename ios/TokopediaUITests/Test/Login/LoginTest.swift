//
//  LoginTest.swift
//  Tokopedia
//
//  Created by nakama on 8/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

class LoginTest: XCTestCase {
    
    var login = LoginPage()
    var more = MorePage()
    var feed = FeedPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if login.isUserLogin() {
            more.goToLogout().doLogout()
        }
        login.goLoginPage()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testLoginValid() {
        login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        
    }
    
    func testLoginInvalid() {
        login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "tokopedia1111").loginUnsuccess()
    }

    
    func testLoginEmptyPassword() {
        login.doLogin(email: "", password: "tokopedia1111").loginUnsuccess()
    }

    func testLoginEmptyEmail() {
        login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "").loginUnsuccess()
    }
}
