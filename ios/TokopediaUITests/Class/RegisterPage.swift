//
//  RegisterPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class Register : LoginPage {
    
    let registerView = app.otherElements["registerView"]
    let registerWithFacebookButton = app.buttons["Facebook"]
    let registerWithGoogleButton = app.buttons["Gooogle"]
    let registerWithYahooButton = app.buttons["Yahoo"]
    let registerWithEmailButton = app.buttons["registerWithEmailButton"]
    
    override func waitForPageLoaded(){
        waitFor(element: registerView, status: .Exists)
    }
    
    func registerWithEmail() -> RegisterWithEmail {
        waitForPageLoaded()
        registerWithEmailButton.tap()
        return RegisterWithEmail()
    }
}

class RegisterWithEmail : Register {
    let registerWithEmailView = app.otherElements["registerWithEmailView"]
    let ragisterEmailScrollView = app.scrollViews["registerEmailScrollView"]
    let registerEmailTextField = app.textFields["emailTextField"]
    let registerNameTextField = app.textFields["nameTextField"]
    let registerHandphoneTextField = app.textFields["phoneNumberTextField"]
    let registerPasswordTextField = app.secureTextFields["passwordTextField"]
    let registerPasswordEye = app.buttons["passwordEyeButton"]
    let registerButton = app.buttons["registerButton"]
    
    override func waitForPageLoaded(){
        waitFor(element: registerWithEmailView, status: .Exists)
    }
    
    func fillRegisterForm(email: String, name: String, handphone : String, password : String)
    {
        registerEmailTextField.tap()
        registerEmailTextField.typeText(email)
        registerNameTextField.tap()
        registerNameTextField.typeText(name)
        registerHandphoneTextField.tap()
        registerHandphoneTextField.typeText(handphone)
        registerPasswordTextField.tap()
        registerPasswordTextField.typeText(password)
        registerPasswordTextField.tap()
        registerButton.tap()
    }
}

class ActivationAccount : Register {
    let accountActivationView = app.otherElements["accountActivationView"]
}

class ResetPasswordSuccess : Register {
    let resetPasswordView = app.otherElements["resetPasswordSuccessView"]
    let resetPasswordLoginButton = app.buttons["loginButton"]
}

