//
//  LoginUITests.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

class LoginUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin(){
        
        let app = XCUIApplication()
        
        self.skipIntro(app:app)
        
        let loginButton = app.tabBars.buttons["Login"]
        loginButton.tap()
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        emailTextField.clearAndEnterText(text: "elly.susilowati+089@tokopedia.com")
        
        let kataSandiSecureTextField = elementsQuery.secureTextFields["Kata Sandi"]
        kataSandiSecureTextField.tap()
        kataSandiSecureTextField.clearAndEnterText(text: "tokopedia2015")
        elementsQuery.buttons["Masuk"].tap()
        
        let exists = NSPredicate(format: "exists == 1")
        let feed = app.scrollViews.otherElements.buttons["FEED"]
        expectation(for: exists, evaluatedWith: feed, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        self.doLogout(app:app)
    }
    
    func testLoginFacebookWithWebview(){
        
        let app = XCUIApplication()
        
        self.skipIntro(app:app)
        
        app.tabBars.buttons["Login"].tap()
        let facebookSignInButton = app.scrollViews.otherElements.buttons["Masuk dengan Facebook"]
        
        // set up an expectation predicate to test whether elements exist
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: facebookSignInButton, handler: nil)
        facebookSignInButton.tap()
        
        // wait for the "Confirm" title at the top of facebook's sign in screen
        let confirmTitle = app.staticTexts["Confirm"]
        expectation(for: exists, evaluatedWith: confirmTitle, handler: nil)
        
        // create a reference to the button through the webView and press it
        let webView = app.descendants(matching: .webView)
        webView.buttons["OK"].tap()
        
        // wait for your app to return and test for expected behavior here
        let feed = app.scrollViews.otherElements.buttons["FEED"]
        waitForElementToAppear(feed)
        
        self.doLogout(app:app)
    }
    
    func testLogout(){
        
        let app = XCUIApplication()
        self.doLogout(app:app)
    }
    
    func doLogout(app:XCUIApplication){
        app.tabBars.buttons["Lainnya"].tap()
        
        let tablesQuery = app.tables
        
        let quitCell = tablesQuery.staticTexts["Keluar"]
        quitCell.swipeUp()
        quitCell.tap()
        app.alerts["Apakah Anda ingin keluar?"].buttons["Iya"].tap()
        
        let tapBarLogin = app.tabBars.buttons["Login"]
        waitForElementToAppear(tapBarLogin)
    }
    
    func skipIntro(app:XCUIApplication){
        
        let elementsQuery = app.scrollViews["intro_scroll"].otherElements
        if app.scrollViews["intro_scroll"].exists {
            elementsQuery.otherElements["intro_page_0"].children(matching: .other).element.swipeLeft()
            elementsQuery.otherElements["intro_page_1"].children(matching: .other).element.swipeLeft()
            elementsQuery.otherElements["intro_page_2"].children(matching: .other).element.swipeLeft()
            elementsQuery.otherElements["intro_page_3"].children(matching: .other).element.swipeLeft()
            
            let elementsQuery = XCUIApplication().scrollViews["intro_scroll"].otherElements
            elementsQuery.buttons["Tidak"].tap()
            elementsQuery.buttons["Masuk"].tap()
            
        }
 
    }
    
    func testWrongUsernameOrPassword(){
        
        let app = XCUIApplication()

        app.tabBars.buttons["Login"].tap()
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("elly.susilosdf@tokopedia.com")
        
        let kataSandiSecureTextField = elementsQuery.secureTextFields["Kata Sandi"]
        kataSandiSecureTextField.tap()
        kataSandiSecureTextField.typeText("tokopedia2015")
        elementsQuery.buttons["Masuk"].tap()
        
        let errorLabel = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element
        waitForElementToAppear(errorLabel)
        
    }
    
    func testNillUsername(){
        
        let app = XCUIApplication()
        app.tabBars.buttons["Login"].tap()
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        emailTextField.tap()
        emailTextField.clearAndEnterText(text: "")
        
        let kataSandiSecureTextField = elementsQuery.secureTextFields["Kata Sandi"]
        kataSandiSecureTextField.tap()
        kataSandiSecureTextField.clearAndEnterText(text: "tokopedia2015")
        elementsQuery.buttons["Masuk"].tap()
        
        let errorLabel = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element
        waitForElementToAppear(errorLabel)
        
    }
    
    func testNillPassword(){
        
        let app = XCUIApplication()
        app.tabBars.buttons["Login"].tap()
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        emailTextField.tap()
        emailTextField.clearAndEnterText(text: "elly.susilosdf@tokopedia.com")
        
        let kataSandiSecureTextField = elementsQuery.secureTextFields["Kata Sandi"]
        kataSandiSecureTextField.tap()
        kataSandiSecureTextField.clearAndEnterText(text: "")
        elementsQuery.buttons["Masuk"].tap()
        
        let errorLabel = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element
        waitForElementToAppear(errorLabel)
        
    }
    
    func testNillUsernameAndPassword(){
        
        let app = XCUIApplication()
        app.tabBars.buttons["Login"].tap()
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        emailTextField.tap()
        emailTextField.clearAndEnterText(text: "")
        
        let kataSandiSecureTextField = elementsQuery.secureTextFields["Kata Sandi"]
        kataSandiSecureTextField.tap()
        emailTextField.clearAndEnterText(text: "")
        elementsQuery.buttons["Masuk"].tap()
        
        let errorLabel = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element
        waitForElementToAppear(errorLabel)
        
    }
    
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = stringValue.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        
        self.typeText(deleteString)
        self.typeText(text)
    }
    
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }

}

extension XCTestCase {
    func waitForElementToAppear(_ element: XCUIElement, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: 5) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after 5 seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
}
