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
    
    let loginTab = app.tabBars.buttons["Login"]
    let loginView = app.tables["loginTableView"]
    let register = app.navigationBars["Masuk"].buttons["Daftar"]
    let emailTextField = app.textFields["emailTextField"]
    let passwordTextField = app.secureTextFields["passwordTextField"]
    let resetPassword = app.buttons["Lupa kata sandi?"]
    let loginButton = app.buttons["loginButton"]
    let touchIdAlert = app.alerts["Integrasi dengan \(NSString.authenticationType())"]
    
    func waitForPageLoaded() {
        waitFor(element: loginView, status: .Exists)
    }
    
    func doLogin(email: String, password: String) {
        waitForPageLoaded()
        emailTextField.tap()
        emailTextField.typeText(email)
        passwordTextField.tap()
        passwordTextField.typeText(password)
        loginButton.tap()
        if waitFor(element: touchIdAlert, status: .Exists) == .completed
        {
            touchIdAlert.buttons["Lewatkan"].tap()
        }
    }
    
    func goToResetPassword() -> ResetPassword {
        waitForPageLoaded()
        resetPassword.tap()
        return ResetPassword()
    }
    
    func goToRegister() -> Register {
        waitForPageLoaded()
        register.tap()
        return Register()
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
}


class ResetPassword : LoginPage {
    let resetemailTextField = app.textFields["Email"]
    let resetPasswordButton = app.buttons["Reset Kata Sandi"]
    
    func fillEmail(email : String) {
        resetemailTextField.tap()
        resetemailTextField.typeText(email)
        resetPasswordButton.tap()
    }
}
