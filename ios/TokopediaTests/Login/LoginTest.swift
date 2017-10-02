//
//  LoginTest.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 10/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest
@testable import Tokopedia

class LoginTest: XCTestCase, AuthenticationServiceProtocol {
//    MARK:- Lifecycle
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = true
    }
    
    override func tearDown() {
        super.tearDown()
    }
//    MARK:- Support functions
    func waitForViewTransition(waitFor:Int) {
        let expectation = XCTestExpectation(description: "Wait for view transition")
        let result = XCTWaiter().wait(for: [expectation], timeout: TimeInterval(waitFor))
        if result == .timedOut {
        } else if result == .completed {
        }
    }

//    MARK:- Test Cases
    func testLoginWithTokopediaAccountNotYetActivated() {
        let service = AuthenticationService.shared
        let email = "elly.susilowati+100b@tokopedia.com" // Email id picked up from test case sheet
        let password = "tokopedia2015"
        service.loginDelegate = self
        service.onLoginComplete = {(_ login: Login?, _ error: Error?)->Void in
            if error != nil {
                XCTAssert(true, "Login failed with inactive account \(email)")
            } else {
                XCTAssert(false, "Login success with inactive account \(email)")
            }
        }
        service.login(withEmail: email, password: password)
        self.waitForViewTransition(waitFor: 15)
    }
    func testLoginWithInvalidAccount() {
        let service = AuthenticationService.shared
        let email = "test@test.com"
        let password = "12345"
        service.loginDelegate = self
        service.onLoginComplete = {(_ login: Login?, _ error: Error?)->Void in
            if error != nil {
                XCTAssert(true, "Login failed with invalid account \(email)")
            } else {
                XCTAssert(false, "Login success with invalid account \(email)")
            }
        }
        service.login(withEmail: email, password: password)
        self.waitForViewTransition(waitFor: 15)
    }
    func testLoginWithEmailPassword() {
        let service = AuthenticationService.shared
        let email = "elly.susilowati+089@tokopedia.com"
        let password = "tokopedia2015"
        service.loginDelegate = self
        service.onLoginComplete = {(_ login: Login?, _ error: Error?)->Void in
            if login != nil {
                XCTAssert(true, "Login success with \(email)")
            } else {
                XCTAssert(false, "Login Failed with \(email)")
            }
        }
        service.login(withEmail: email, password: password)
        self.waitForViewTransition(waitFor: 15)
    }
//MARK:- AuthenticationServiceProtocol
    func showVerifyLoginScreen(sender: AuthenticationService, onCompletion:@escaping(_ error: Error?)->Void) {
        XCTAssert(true, "Login success")
    }
    func showCreatePasswordScreen(sender: AuthenticationService, onCompletion:@escaping(_ error: Error?)->Void) {
        XCTAssert(true, "Login success")
    }

}
