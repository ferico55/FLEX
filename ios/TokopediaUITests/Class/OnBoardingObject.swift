//
//  OnBoardingClass.swift
//  Tokopedia
//
//  Created by nakama on 8/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

public class onBoarding {
    
    static let app = XCUIApplication()
    static let boardingView = app.scrollViews.containing( .scrollView, identifier:"intro_scroll")
    static let introPage1 = app.otherElements["intro_page_0"]
    static let introPage2 = app.otherElements["intro_page_1"]
    static let introPage3 = app.otherElements["intro_page_2"]
    static let introPage4 = app.otherElements["intro_page_3"]

    
    static let turnOffNotifButton = app.scrollViews["intro_scroll"].otherElements.buttons["Tidak"]
    static let turnOnNotifButton = app.scrollViews["intro_scroll"].otherElements.buttons["Aktifkan Notifikasi"]
    
    static let loginButton = app.buttons["Masuk"]
    
    static let notifAlert = app.scrollViews["intro_scroll"].otherElements.alerts["“Tokopedia” Would Like to Send You Notifications"]
    
    
    static func isOnBoarding() ->Bool {
        if(boardingView.count) > 0 {
            return true
        }
        else{
            return false
        }
    }
    
    static func skipOnBoarding() {
        onBoarding.swipeOnBoarding()
        onBoarding.turnOffNotifButton.tap()
        onBoarding.loginButton.tap()
    }
    
    static func swipeOnBoarding() {
        introPage1.swipeLeft()
        introPage2.swipeLeft()
        introPage3.swipeLeft()
        introPage4.tap()
    }
    
    
    
}
