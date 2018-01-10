//
//  ResetPasswordTest.swift
//  Tokopedia
//
//  Created by nakama on 8/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class ResetPasswordTest: XCTestCase {
    
    var login = LoginPage()
    var register = Register()
    var resetPassword = ResetPassword()
    var more = MorePage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if login.isUserLogin(){
            more.goToLogout().doLogout()
        }
        login.goToResetPassword()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testResetPassword() {
        resetPassword.fillEmail(email : "julius.gonawan+automationbuyer@tokopedia.com")
        resetPassword.resetPasswordButton.tap()
        XCTAssert(resetPassword.resetPasswordButton.exists)
    }
    
    func testEmptyResetPassword() {
        resetPassword.fillEmail(email : "")
        resetPassword.resetPasswordButton.tap()
        XCTAssert(resetPassword.resetPasswordButton.exists)
    }
    
    func testDoRegisterResetPassword() {
        resetPassword.fillEmail(email : "hanyauntuktesting20171@gmail.com")
        resetPassword.resetPasswordButton.tap()
        Page.app.alerts["Email hanyauntuktesting20171@gmail.com belum terdaftar sebagai member Tokopedia"].buttons["OK"].tap()
        XCTAssert(register.registerView.exists)
    }
    
    func testDoNotRegisterResetPassword() {
        resetPassword.fillEmail(email : "hanyauntuktesting20171@gmail.com")
        resetPassword.resetPasswordButton.tap()
        Page.app.alerts["Email hanyauntuktesting20171@gmail.com belum terdaftar sebagai member Tokopedia"].buttons["Tidak"].tap()
        XCTAssert(resetPassword.resetPasswordButton.exists)
    }
}
