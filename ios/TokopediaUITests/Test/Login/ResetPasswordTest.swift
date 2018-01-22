//
//  ResetPasswordTest.swift
//  Tokopedia
//
//  Created by nakama on 8/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class ResetPasswordTest: XCTestCase {
    
    var homePage : HomePage = HomePage()
    var register : Register = Register()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if homePage.isUserLogin(){
            homePage.goMorePage().doLogout()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testResetPassword() {
        let resetPassword = homePage.goLoginPage().goToResetPassword()
        resetPassword.fillEmail(email : "julius.gonawan+automationbuyer@tokopedia.com")
        XCTAssert(resetPassword.resetPasswordButton.exists)
    }
    
    func testEmptyResetPassword() {
        let resetPassword = homePage.goLoginPage().goToResetPassword()
        resetPassword.fillEmail(email : "")
        XCTAssert(resetPassword.resetPasswordButton.exists)
    }

    func testDoRegisterResetPassword() {
        let resetPassword = homePage.goLoginPage().goToResetPassword()
        resetPassword.fillEmail(email : "hanyauntuktesting2018@gmail.com")
        Page.app.alerts["Email hanyauntuktesting2018@gmail.com belum terdaftar sebagai member Tokopedia"].buttons["OK"].tap()
        XCTAssert(register.registerView.exists)
    }

    func testDoNotRegisterResetPassword() {
        let resetPassword = homePage.goLoginPage().goToResetPassword()
        resetPassword.fillEmail(email : "hanyauntuktesting2018@gmail.com")
        Page.app.alerts["Email hanyauntuktesting2018@gmail.com belum terdaftar sebagai member Tokopedia"].buttons["Tidak"].tap()
        XCTAssert(resetPassword.resetPasswordButton.exists)
    }
}

