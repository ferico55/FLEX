//
//  LoginPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class LoginPage : Page, TokopediaTabBar {
    
    var more = MorePage()
    var feed = FeedPage()
    
    let loginTab = app.tabBars.buttons["Login"]
    let loginView = app.tables["loginTableView"]
    let register = app.navigationBars["Masuk"].buttons["Daftar"]
    let emailTextField = app.textFields["emailTextField"]
    let passwordTextField = app.secureTextFields["passwordTextField"]
    let resetPassword = app.buttons["Lupa kata sandi?"]
    let loginButton = app.buttons["loginButton"]
    let touchIdAlert = app.alerts["Integrasi dengan Touch ID"]
    
    func waitForPageLoaded(){
        waitFor(element: loginView, status: .Exists)
    }
    
    func goToRegister() {
        goLoginPage()
        waitForPageLoaded()
        register.tap()
    }
    
    func goToResetPassword() {
        goLoginPage()
        waitForPageLoaded()
        resetPassword.tap()
    }
    
    func doLogin(email: String, password: String) -> CheckLogin{
        waitForPageLoaded()
        emailTextField.tap()
        emailTextField.typeText(email)
        passwordTextField.tap()
        passwordTextField.typeText(password)
        loginButton.tap()
        return CheckLogin()
    }
    
    func isUserLogin() -> Bool {
        if (moreTabBar.exists)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func isShouldLogin() -> Bool {
        if(loginView.exists)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func isLogout() -> Bool {
        if(loginTab.exists)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func swithAccountSeller() {
        more.goToLogout().doLogout()
        doLogin(email: "julius.gonawan+seller@tokopedia.com", password: "tokopedia2016").loginSuccess()
    }
}

class CheckLogin : LoginPage {
    func loginSuccess(){
        
        waitFor(element: feed.feedView, status: .Exists)
        XCTAssert(feed.feedView.exists)
    }
    
    func loginUnsuccess() {
        XCTAssert(loginButton.exists)
    }
}


class ResetPassword : LoginPage {
    let resetemailTextField = app.textFields["Email"]
    let resetPasswordButton = app.buttons["Reset Kata Sandi"]
    
    func fillEmail(email : String) {
        resetemailTextField.tap()
        resetemailTextField.typeText(email)
    }
}
