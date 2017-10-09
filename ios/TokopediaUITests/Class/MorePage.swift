//
//  MorePage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class MorePage : Page, TokopediaTabBar {
    let logoutButton = app.tables.staticTexts["Keluar"]
    let logoutAlert = app.alerts["Apakah Anda ingin keluar?"]
    
    func waitForLogout(){
        waitFor(element: logoutButton, status: .Exists)
    }
    
    func goToLogout() -> Logout {
        goMorePage()
        waitFor(element: logoutButton, status: .Exists)
        logoutButton.tap()
        return Logout()
    }
}

class Logout : MorePage {
    func doLogout() {
        logoutAlert.buttons["Iya"].tap()
    }
}
