////
////  InboxTalkTest.swift
////  Tokopedia
////
////  Created by Elly Susilowati on 10/18/17.
////  Copyright © 2017 TOKOPEDIA. All rights reserved.
////
//
//import Foundation
//import XCTest
//
//class inboxTest : XCTestCase
//{
//    var home = HomePage()
//    var more = MorePage()
//    var login = LoginPage()
//    var talkPage = InboxTalk()
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//        Page.app.launch()
//        UITest.sharedInstance.testCase = self
//        XCUIApplication().launchEnvironment = ["animations": "0"]
//        
//        if onBoarding.isOnBoarding() {
//            onBoarding.skipOnBoarding()
//        }
//        
//        if login.isLogout(){
//            home.goLoginPage()
//            login.doLogin(email: "alwan.ubaidillah+101@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        }else{
//            more.goMorePage()
//            more.goToLogout().doLogout()
//            sleep(2)
//            home.goLoginPage()
//            login.doLogin(email: "alwan.ubaidillah+101@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        }
//        
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    func testInboxTalk()
//    {
//        talkPage.goToDetail()
//        talkPage.insertTalk()
//    }
//    
//    func testAttach()
//    {
//        more.goToInboxTalk()
//        waitFor(element: talkPage.comment, status: .Exists)
//        talkPage.comment.tap()
//        waitFor(element: talkPage.attach, status: .Exists)
//        talkPage.attach.tap()
//    }
//    
//    func testFollowUnfollow()
//    {
//        more.goToInboxTalk()
//        let before = talkPage.follow.label
//        talkPage.follow.tap()
//        XCTAssertTrue(before != talkPage.follow.label)
//        sleep(2)
//        talkPage.follow.tap()
//        XCTAssertTrue(talkPage.follow.label == before)
//    }
//    
////    func testFollowTalk()
////    {
////        talkPage.goToInboxTalk()
////        talkPage.follow.tap()
////        
////    }
//}

