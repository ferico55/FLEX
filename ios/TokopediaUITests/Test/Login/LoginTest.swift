//
//  LoginTest.swift
//  Tokopedia
//
//  Created by nakama on 8/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

class LoginTest: XCTestCase {
    
    var homePage : HomePage = HomePage()
    var feed : FeedPage = FeedPage()
    var login : LoginPage = LoginPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if homePage.isUserLogin() {
            homePage.goMorePage().doLogout()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoginBuyer() {
        homePage.goLoginPage().doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016")
        waitFor(element: homePage.homeTab, status: .Exists)
        homePage.homeTab.tap()
    }
    
    func testLoginSeller() {
        homePage.goLoginPage().doLogin(email: "julius.gonawan+automationseller@tokopedia.com", password: "tokopedia2016")
        waitFor(element: feed.feedView, status: .Exists)
        XCTAssert(feed.feedView.exists)
        homePage.homeTab.tap()
    }
    
    func testLoginUnsuccess() {
        homePage.goLoginPage().doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia1111")
        XCTAssert(login.loginButton.exists)
    }

    
    func testLoginEmptyPassword() {
        homePage.goLoginPage().doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "")
        XCTAssert(login.loginButton.exists)
    }

    func testLoginEmptyEmail() {
        homePage.goLoginPage().doLogin(email: "", password: "tokopedia2016")
        XCTAssert(login.loginButton.exists)
    }
}
