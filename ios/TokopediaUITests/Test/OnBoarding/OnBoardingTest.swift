//
//  TokopediaUITests.swift
//  TokopediaUITests
//
//  Created by nakama on 8/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

//import XCTest
//
//class OnBoardingTest: XCTestCase {
//    
//    let app = XCUIApplication()
//    var login = Login()
//    
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//        XCUIApplication().launch()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    func waitforlogin() {
//        let predict = login.loginView
//        let exists = NSPredicate(format: "exists == true")
//        expectation(for: exists, evaluatedWith: predict, handler: nil)
//        waitForExpectations(timeout: 20, handler: nil)
//    }
//    
//    func testTurnOffNotif() {
//        
//        onBoarding.swipeOnBoarding()
//    
//        onBoarding.turnOffNotifButton.tap()
//        
//        onBoarding.loginButton.tap()
//        
//    }
//    
//    func testTurnOnNotif() {
//       
//        onBoarding.swipeOnBoarding()
//        
//        onBoarding.turnOnNotifButton.tap()
//        
//        //sometimes can not detect, need to recheck
//        onBoarding.notifAlert.buttons["Allow"].tap()
//        
//        //tap the screen again
//        app.otherElements["intro_page_5"].tap()
//        
//        onBoarding.loginButton.tap()
//        
//    }
//    
//}
